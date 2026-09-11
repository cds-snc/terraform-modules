import os
import sys
import unittest

from unittest.mock import patch, MagicMock


class TestSentinelForwarder(unittest.TestCase):
    def test_lambda_handler(self):
        event = {"foo": "bar"}

        # Mock the connector module and add it to sys.modules
        # This is necessary because the connector module is imported via a Lambda layer
        mock_connector = MagicMock()
        sys.modules["connector"] = mock_connector

        with (
            patch.dict(
                "os.environ",
                {
                    "CUSTOMER_ID": "foo",
                    "SHARED_KEY": "bar",
                    "AWS_REGION": "ca-central-1",
                    "SENTINEL_AUTH_PARAMS_ARN": "TheARN",
                },
            ),
            patch("boto3.client") as mock_boto3_client,
        ):
            mock_boto3_client().get_parameter.return_value = {
                "Parameter": {"Value": "CUSTOMER_ID=boom\nSHARED_KEY=baz=="}
            }
            import sentinel_forwarder

            sentinel_forwarder.lambda_handler(event, None)

            assert os.environ["CUSTOMER_ID"] == "boom"
            assert os.environ["SHARED_KEY"] == "baz=="

        mock_connector.handle_log.assert_called_once_with(event)
        mock_boto3_client.assert_called_with("ssm", region_name="ca-central-1")
        mock_boto3_client().get_parameter.assert_called_once_with(
            Name="TheARN",
            WithDecryption=True,
        )

        # Clean up by removing the mock from sys.modules
        del sys.modules["connector"]
        del sys.modules["sentinel_forwarder"]

    def test_no_auth_params_arn_skips_ssm(self):
        """
        The secretless Logs Ingestion path creates no SSM parameter, so the
        module must import without one. Reading it unconditionally would fail
        the cold start before the handler ever runs.
        """
        event = {"foo": "bar"}

        mock_connector = MagicMock()
        sys.modules["connector"] = mock_connector
        sys.modules.pop("sentinel_forwarder", None)

        env = {
            "AWS_REGION": "ca-central-1",
            "DCE_ENDPOINT": "https://example.ingest.monitor.azure.com",
            "DCR_CONFIG": '{"AWSSecurityHub": {"dcrImmutableId": "dcr-1", "streamName": "Custom-x"}}',
        }

        with (
            patch.dict("os.environ", env, clear=True),
            patch("boto3.client") as mock_boto3_client,
        ):
            import sentinel_forwarder

            sentinel_forwarder.lambda_handler(event, None)

            mock_boto3_client.assert_not_called()

        mock_connector.handle_log.assert_called_once_with(event)

        del sys.modules["connector"]
        del sys.modules["sentinel_forwarder"]
