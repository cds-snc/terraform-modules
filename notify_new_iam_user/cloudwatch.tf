#
# Create cloudwatch resources
#

resource "aws_cloudwatch_event_rule" "new_iam_user_added_event_rule" {
  event_pattern = <<EOF
{
  "source": ["aws.iam"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["iam.amazonaws.com"],
    "eventName": ["CreateUser"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "new_iam_user_added_event_target" {
  rule      = aws_cloudwatch_event_rule.new_iam_user_added_event_rule.name
  target_id = "new_iam_user_added_lambda"
  arn       = aws_lambda_function.new_iam_user_added_lambda.arn
}

# create cloudwatch log group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.new_iam_user_added_lambda.function_name}"
  retention_in_days = 14
  lifecycle {
    prevent_destroy = false
  }
}
