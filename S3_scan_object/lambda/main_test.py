import main

from unittest.mock import patch

class LambdaContext:
  def __init__(self, aws_request_id):
    self.aws_request_id = aws_request_id

@patch("main.client")
@patch("main.json.loads")
@patch("main.ACCOUNT_ID", "GeneralKenobi")
@patch("main.S3_SCAN_OBJECT_FUNCTION_ARN", "arn:aws:lambda:ca-central-1:123456789012:function:anakin")
def test_handler(mock_json_loads, mock_client):
  main.handler({"Hello": "There"}, LambdaContext("1234asdf-5678-ghjk-9012-qwer12324poiy5678"))
  mock_client.invoke.assert_called_with(
    FunctionName='arn:aws:lambda:ca-central-1:123456789012:function:anakin', 
    Payload='{"Hello": "There", "AccountId": "GeneralKenobi", "RequestId": "1234asdf-5678-ghjk-9012-qwer12324poiy5678"}'
  )