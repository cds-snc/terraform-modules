/* 
* # Disable exposed IAM credentials
*
* This module sets up a lambda that will disable an IAM access key triggered by an AWS Health notification with the AWS_RISK_CREDENTIALS_EXPOSED event type.
*/

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#
# Lambda: Disable exposed IAM credential
#

resource "aws_lambda_function" "disable_exposed_iam_credential" {
  function_name = var.function_name
  description   = "Lambda function to disable exposed IAM credentials"

  filename    = data.archive_file.disable_exposed_iam_credential.output_path
  handler     = "disable_exposed_iam_credential.lambda_handler"
  runtime     = "python3.9"
  timeout     = 30
  memory_size = 128

  role             = aws_iam_role.disable_exposed_iam_credential_lambda.arn
  source_code_hash = filebase64sha256(data.archive_file.disable_exposed_iam_credential.output_path)

  tracing_config {
    mode = "Active"
  }

  depends_on = [
    aws_iam_role_policy_attachment.disable_exposed_iam_credential_lambda,
    aws_cloudwatch_log_group.disable_exposed_iam_credential_lambda,
  ]

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
  }
}

data "archive_file" "disable_exposed_iam_credential" {
  type        = "zip"
  source_file = "${path.module}/functions/disable_exposed_iam_credential.py"
  output_path = "/tmp/disable_exposed_iam_credential.py.zip"
}

#
# EventBridge: IAM credential exposed event
#

resource "aws_cloudwatch_event_rule" "exposed_iam_credential_found_rule" {
  name          = "exposed-iam-credential-found-rule"
  event_pattern = <<-PATTERN
    {
        "source": ["aws.health"],
        "detail": {
            "service": ["ABUSE"],
            "eventTypeCode": ["AWS_RISK_CREDENTIALS_EXPOSED"]
        }
    }
PATTERN
}

resource "aws_lambda_permission" "disable_exposed_iam_credential_events" {
  statement_id   = "AllowExecutionFromEvents-${var.function_name}"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.disable_exposed_iam_credential.function_name
  principal      = "events.amazonaws.com"
  source_arn     = aws_cloudwatch_event_rule.exposed_iam_credential_found_rule.arn
  source_account = data.aws_caller_identity.current.account_id
}

resource "aws_cloudwatch_event_target" "disable_exposed_iam_credential" {
  target_id = "DisableExposedIAMCredentialsEventTarget"
  rule      = aws_cloudwatch_event_rule.exposed_iam_credential_found_rule.name
  arn       = aws_lambda_function.disable_exposed_iam_credential.arn
}

#
# CloudWatch: Lambda logs
#
resource "aws_cloudwatch_log_group" "disable_exposed_iam_credential_lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = "14"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
  }
}
