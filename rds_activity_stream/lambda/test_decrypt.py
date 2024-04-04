import json
import pytest
import zlib
from unittest.mock import patch

from aws_encryption_sdk.identifiers import WrappingAlgorithm, EncryptionKeyType
from aws_encryption_sdk.key_providers.raw import RawMasterKeyProvider, WrappingKey

from decrypt import (
    get_filtered_events,
    handler,
    decrypt_decompress,
    decrypt_payload,
    MyRawMasterKeyProvider,
)


@pytest.fixture
def sample_event():
    return {
        "records": [
            {
                "recordId": "12345",
                "data": "ewogICJ0eXBlIjoiRGF0YWJhc2VBY3Rpdml0eU1vbml0b3JpbmdSZWNvcmRzIiwKICAidmVyc2lvbiI6IjEuMyIsCiAgImRhdGFiYXNlQWN0aXZpdHlFdmVudHMiOiJaVzVqY25sd2RHVmtJR0YxWkdsMElISmxZMjl5WkhNSyIsCiAgImtleSI6IlpXNWpjbmx3ZEdWa0lHdGxlUW89Igp9",
            },
        ]
    }


@patch("decrypt.decrypt_decompress")
@patch("decrypt.kms.decrypt")
def test_handler(mock_kms_decrypt, mock_decrypt_decompress, sample_event):
    mock_decrypt_decompress.return_value = (
        b'{"databaseActivityEventList":[{"type":"READ"}]}'
    )
    mock_kms_decrypt.return_value = {
        "Plaintext": b"sample_plaintext",
        "KeyId": "sample_rds_activity_stream_id",
    }

    result = handler(sample_event, None)

    mock_decrypt_decompress.assert_called_with(
        b"encrypted audit records\n", b"sample_plaintext"
    )
    mock_kms_decrypt.assert_called_with(
        CiphertextBlob=b"encrypted key\n",
        EncryptionContext={"aws:rds:dbc-id": "cluster-0123456789"},
    )

    assert result == {
        "records": [
            {
                "data": b"eyJkYXRhYmFzZUFjdGl2aXR5RXZlbnRMaXN0IjogW3sidHlwZSI6ICJSRUFEIn1dfQ==",
                "recordId": "12345",
                "result": "Ok",
            }
        ]
    }


def test_my_raw_master_key_provider_initialization():
    sample_plain_key = b"sample_plain_key"
    with patch.object(RawMasterKeyProvider, "__init__", return_value=None):
        with patch.object(
            WrappingKey, "__init__", return_value=None
        ) as mock_wrapping_key_init:
            my_key_provider = MyRawMasterKeyProvider(sample_plain_key)

            mock_wrapping_key_init.assert_called_once_with(
                wrapping_algorithm=WrappingAlgorithm.AES_256_GCM_IV12_TAG16_NO_PADDING,
                wrapping_key=sample_plain_key,
                wrapping_key_type=EncryptionKeyType.SYMMETRIC,
            )

            assert my_key_provider.provider_id == "BC"
            assert isinstance(my_key_provider.wrapping_key, WrappingKey)


def test_my_raw_master_key_provider_get_raw_key():
    sample_plain_key = b"sample_plain_key"
    my_key_provider = MyRawMasterKeyProvider(sample_plain_key)
    assert my_key_provider._get_raw_key("DataKey") == my_key_provider.wrapping_key


@patch("decrypt.MyRawMasterKeyProvider")
@patch(
    "decrypt.aws_encryption_sdk.materials_managers.default.DefaultCryptoMaterialsManager"
)
@patch("decrypt.enc_client.decrypt")
def test_decrypt_payload(mock_decrypt, mock_materials_manager, mock_key_provider):
    mock_decrypt.return_value = (b"decrypted_plaintext", "header")
    mock_key_provider_instance = mock_key_provider.return_value
    mock_materials_manager_instance = mock_materials_manager.return_value
    payload = b"encrypted_payload"
    data_key = b"data_key"

    result = decrypt_payload(payload, data_key)

    mock_key_provider.assert_called_once_with(data_key)
    mock_key_provider_instance.add_master_key.assert_called_once_with("DataKey")
    mock_materials_manager.assert_called_once_with(
        master_key_provider=mock_key_provider_instance
    )
    mock_decrypt.assert_called_once_with(
        source=payload, materials_manager=mock_materials_manager_instance
    )
    assert result == b"decrypted_plaintext"


@patch("decrypt.decrypt_payload")
@patch("decrypt.zlib.decompress")
def test_decrypt_decompress(mock_decompress, mock_decrypt_payload):
    mock_decrypt_payload.return_value = b"decrypted_payload"
    mock_decompress.return_value = b"decompressed_payload"
    payload = b"encrypted_payload"
    key = b"data_key"

    result = decrypt_decompress(payload, key)

    mock_decrypt_payload.assert_called_once_with(payload, key)
    mock_decompress.assert_called_once_with(b"decrypted_payload", zlib.MAX_WBITS + 16)
    assert result == b"decompressed_payload"


def test_get_filtered_events_all_valid():
    plaintext_events = json.dumps(
        {"databaseActivityEventList": [{"type": "READ"}, {"type": "WRITE"}]}
    )
    result = get_filtered_events(plaintext_events)

    assert result is not None
    result_json = json.loads(result)
    assert "databaseActivityEventList" in result_json
    assert len(result_json["databaseActivityEventList"]) == 2


def test_get_filtered_events_with_some_valid():
    plaintext_events = json.dumps(
        {
            "databaseActivityEventList": [
                {"type": "READ"},
                {"type": "heartbeat"},
                {"type": "WRITE"},
                {"dbUserName": "rdsproxyadmin"},
            ]
        }
    )
    result = get_filtered_events(plaintext_events)

    assert result is not None
    result_json = json.loads(result)
    assert "databaseActivityEventList" in result_json
    assert len(result_json["databaseActivityEventList"]) == 2
    assert all(
        event["type"] != "heartbeat"
        for event in result_json["databaseActivityEventList"]
    )


def test_get_filtered_events_all_filtered():
    plaintext_events = json.dumps(
        {
            "databaseActivityEventList": [
                {"type": "heartbeat"},
                {"dbUserName": "rdsproxyadmin"},
            ]
        }
    )
    result = get_filtered_events(plaintext_events)

    assert result is None


def test_get_filtered_events_empty():
    plaintext_events = json.dumps({"databaseActivityEventList": []})
    result = get_filtered_events(plaintext_events)

    assert result is None
