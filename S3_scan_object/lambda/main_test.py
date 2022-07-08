import main

from unittest.mock import patch

@patch("main.client")
@patch("main.json.loads")
@patch("main.uuid.uuid4", return_value="1234asdf-5678-ghjk-9012-qwer12324poiy5678")
@patch("main.ACCOUNT_ID", "GeneralKenobi")
@patch("main.S3_SCAN_OBJECT_FUNCTION_ARN", "arn:aws:lambda:ca-central-1:123456789012:function:anakin")
def test_handler(mock_uuid, mock_json_loads, mock_client):
  main.handler({"Hello": "There"}, None)
  mock_client.invoke.assert_called_with(
    FunctionName='arn:aws:lambda:ca-central-1:123456789012:function:anakin', 
    Payload='{"Hello": "There", "AccountId": "GeneralKenobi", "RequestId": "1234asdf-5678-ghjk-9012-qwer12324poiy5678"}'
  )