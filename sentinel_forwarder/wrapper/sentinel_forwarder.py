"""
Provides a wrapper for the Sentinel Forwarder that simplifies sending events and logs
to Sentinel.
"""

import os

import boto3
import connector  # pylint: disable=import-error

AWS_REGION = os.getenv("AWS_REGION")
SENTINEL_AUTH_PARAMS_ARN = os.getenv("SENTINEL_AUTH_PARAMS_ARN")


def set_env_vars(params_arn):
    """
    Loads sensitive environment variables from SSM Parameter Store
    It expects the parameters to be in the following format:

    CUSTOMER_ID=value1
    SHARED_KEY=value2
    """
    ssm = boto3.client("ssm", region_name=AWS_REGION)
    sentinel_auth_params = ssm.get_parameter(Name=params_arn, WithDecryption=True)[
        "Parameter"
    ]["Value"]
    for param in sentinel_auth_params.split("\n"):
        key, value = param.split("=", 1)
        os.environ[key] = value


# Env vars are retrieved outside the handler to avoid lookups on every invocation
set_env_vars(SENTINEL_AUTH_PARAMS_ARN)


def lambda_handler(event, _context):
    """Passes the event to the Sentinel connector layer"""
    try:
        connector.handle_log(event)
        return True
    except Exception as e:  # pylint: disable=broad-exception-caught
        print(e)
    return False
