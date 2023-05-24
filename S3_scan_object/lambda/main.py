"""
Forwards an event to a lambda function given by the S3_SCAN_OBJECT_FUNCTION_ARN
environment variable.  The original event is passed as the payload to the lambda
along with the ACCOUNT_ID environment variable.
"""
import boto3
import logging
import json
import os

ACCOUNT_ID=os.environ.get("ACCOUNT_ID")
LOG_LEVEL=os.environ.get("LOG_LEVEL", logging.INFO)
S3_SCAN_OBJECT_FUNCTION_ARN=os.environ.get("S3_SCAN_OBJECT_FUNCTION_ARN")

client = boto3.client("lambda")
logger = logging.getLogger()
logger.setLevel(LOG_LEVEL)

def handler(event, context):
  status = "OK"
  event["AccountId"] = ACCOUNT_ID
  event["RequestId"] = context.aws_request_id

  logger.debug(event)
  logger.debug(f"[{event['RequestId']}] Invoking {S3_SCAN_OBJECT_FUNCTION_ARN}")

  try:
    client.invoke(
      FunctionName=S3_SCAN_OBJECT_FUNCTION_ARN,
      InvocationType="Event",
      Payload=json.dumps(event),
    )
  except Exception as err:
    logger.error(f"[{event['RequestId']}] Error invoking function: {err}")
    status = "ERROR"

  return {status: status}
