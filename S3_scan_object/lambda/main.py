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
LOG_LEVEL=os.environ.get("LOG_LEVEL", logging.ERROR)
S3_SCAN_OBJECT_FUNCTION_ARN=os.environ.get("S3_SCAN_OBJECT_FUNCTION_ARN")

client = boto3.client("lambda")
logger = logging.getLogger()
logger.setLevel(LOG_LEVEL)

def handler(event, context):
  event["AccountId"] = ACCOUNT_ID
  logger.info(event)

  client_response = client.invoke(
    FunctionName=S3_SCAN_OBJECT_FUNCTION_ARN,
    Payload=json.dumps(event),
  )
  
  response = json.loads(client_response["Payload"].read().decode("utf-8"))
  logger.info(response)

  return response
