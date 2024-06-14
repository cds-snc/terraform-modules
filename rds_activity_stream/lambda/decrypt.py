# pylint: disable=line-too-long
"""
Kinesis Firehose Lambda function to process RDS activity stream records.  This is based off
the example provided by AWS:
https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/DBActivityStreams.Monitoring.html#DBActivityStreams.CodeExample
"""
import base64
import json
import logging
import os
import zlib

import boto3
import aws_encryption_sdk
from aws_encryption_sdk import CommitmentPolicy
from aws_encryption_sdk.internal.crypto import WrappingKey
from aws_encryption_sdk.key_providers.raw import RawMasterKeyProvider
from aws_encryption_sdk.identifiers import WrappingAlgorithm, EncryptionKeyType

AWS_REGION = os.environ.get("AWS_REGION")
RDS_ACTIVITY_STREAM_NAME = os.environ.get("RDS_ACTIVITY_STREAM_NAME")
RDS_ACTIVITY_STREAM_ID = RDS_ACTIVITY_STREAM_NAME[len("aws-rds-das-") :]

enc_client = aws_encryption_sdk.EncryptionSDKClient(
    commitment_policy=CommitmentPolicy.FORBID_ENCRYPT_ALLOW_DECRYPT
)
kms = boto3.client("kms", region_name=AWS_REGION)
logging.getLogger().setLevel(logging.ERROR)


def handler(event, _context):
    """
    Handle the RDS activity stream events.  Decrypt and decompress the payload and returns
    the plaintext data.
    """
    output = []

    for record in event["records"]:
        record_data = base64.b64decode(record["data"])
        record_data = json.loads(record_data)
        payload_decoded = base64.b64decode(record_data["databaseActivityEvents"])
        data_key_decoded = base64.b64decode(record_data["key"])
        data_key_decrypt_result = kms.decrypt(
            CiphertextBlob=data_key_decoded,
            EncryptionContext={"aws:rds:dbc-id": RDS_ACTIVITY_STREAM_ID},
        )
        plain_text = decrypt_decompress(
            payload_decoded, data_key_decrypt_result["Plaintext"]
        )

        filtered_events = get_filtered_events(plain_text)
        if filtered_events:
            output_record = {
                "recordId": record["recordId"],
                "result": "Ok",
                "data": base64.b64encode(filtered_events.encode("utf-8")),
            }
        else:
            output_record = {
                "recordId": record["recordId"],
                "result": "Dropped",
                "data": base64.b64encode(b"Event filtered"),
            }
        output.append(output_record)

    return {"records": output}


class MyRawMasterKeyProvider(RawMasterKeyProvider):
    """
    Takes the raw key matrial and provides a WrappingKey
    that can be used for cryptographic operations.
    """

    provider_id = "BC"

    def __new__(cls, *args, **kwargs):
        obj = super(RawMasterKeyProvider, cls).__new__(cls)
        return obj

    def __init__(self, plain_key):
        RawMasterKeyProvider.__init__(self)
        self.wrapping_key = WrappingKey(
            wrapping_algorithm=WrappingAlgorithm.AES_256_GCM_IV12_TAG16_NO_PADDING,
            wrapping_key=plain_key,
            wrapping_key_type=EncryptionKeyType.SYMMETRIC,
        )

    def _get_raw_key(self, key_id):
        return self.wrapping_key


def decrypt_payload(payload, data_key):
    """
    Decrypt the payload using the AWS Encryption SDK and the provided raw data key.
    """
    my_key_provider = MyRawMasterKeyProvider(data_key)
    my_key_provider.add_master_key("DataKey")
    decrypted_plaintext, _header = enc_client.decrypt(
        source=payload,
        materials_manager=aws_encryption_sdk.materials_managers.default.DefaultCryptoMaterialsManager(
            master_key_provider=my_key_provider
        ),
    )
    return decrypted_plaintext


def decrypt_decompress(payload, key):
    """
    Decrypt and decompress the payload using the provided key.
    """
    decrypted = decrypt_payload(payload, key)
    return zlib.decompress(decrypted, zlib.MAX_WBITS + 16)


def get_filtered_events(plaintext_events):
    """
    Determine if the database event should be included in the output.
    Currently filters out all heartbeat and RDS proxy admin events.
    """
    events = json.loads(plaintext_events)
    db_activity = events.get("databaseActivityEventList", [])
    db_activity_filtered = [
        event
        for event in db_activity
        if event.get("type") != "heartbeat"
        and event.get("dbUserName") != "rdsproxyadmin"
    ]

    if db_activity_filtered:
        events["databaseActivityEventList"] = db_activity_filtered
        return json.dumps(events)
    return None
