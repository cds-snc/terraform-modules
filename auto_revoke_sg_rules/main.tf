/* 
* Automatically revoke security group changes on SSH and RDP ports (22 and 3389) 
*
* This module sets up a lambda that will automatically revert any security group changes that open the SSH and RDP ports.
*/

# Get the current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Lambda: Disable secruity group exposure to ports 22 and 3389 
#
data "archive_file" "sg_change_auto_response" {
  type        = "zip"
  source_file = "${path.module}/functions/sg_change_auto_response.py"
  output_path = "/tmp/sg_change_auto_response.py.zip"
}

# Lambda function that is used for security group auto-response
resource "aws_lambda_function" "security_group_change_auto_response" {
  function_name = "security_group_change_auto_response"
  description   = "Responds to security group changes"
  role          = aws_iam_role.group_change_auto_response_role.arn
  handler       = "sg_change_auto_response.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60

  filename         = data.archive_file.sg_change_auto_response.output_path
  source_code_hash = filebase64sha256(data.archive_file.sg_change_auto_response.output_path)

  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      sns_topic_arn = "arn:aws:sns:${local.region}:${local.account_id}:internal-sre-alert"
    }
  }
  depends_on = [
    aws_iam_role.group_change_auto_response_role
  ]
}


#
# EventBridge: Catch and trigger security group changes 
#
resource "aws_cloudwatch_event_rule" "sg_change_auto_response_event_rule" {
  name          = "security_group_change_auto_response"
  description   = "Responds to security group change events"
  is_enabled    = true
  event_pattern = <<PATTERN
    {
        "detail-type": [
            "AWS API Call via CloudTrail"
        ],
        "detail": {
            "eventSource": [
              "ec2.amazonaws.com"
            ],
            "eventName": [
            "AuthorizeSecurityGroupIngress",
            "AuthorizeSecurityGroupEgress",
            "RevokeSecurityGroupIngress",
            "RevokeSecurityGroupEgress",
            "CreateSecurityGroup",
            "DeleteSecurityGroup"
            ]
        }
    }
    PATTERN
}

# Target that triggers the Lambda function
resource "aws_cloudwatch_event_target" "target_sg_change_auto_response_event_rule" {
  rule = aws_cloudwatch_event_rule.sg_change_auto_response_event_rule.name
  arn  = aws_lambda_function.security_group_change_auto_response.arn
}

# Permission that allows the Cloudwatch service to execute the Lambda function
resource "aws_lambda_permission" "security_group_change_auto_response_lambda_permission" {
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.security_group_change_auto_response.function_name
}
