/** 
* # CloudWatch Slack
*
* This module creates a Lambda function posts messages to a Slack channel when a CloudWatch alarm changes state.
*
* ## Setup
*
* 1. Create a [Slack App with an incoming webhook](https://api.slack.com/messaging/webhooks) for the channel you'd like to post in.
* 1. Create one or more SNS Topics and subscribe them to this module's Lambda ARN output.
* 1. Setup CloudWatch Alarms that send their state changes to the SNS Topics.
*
* The above is shown in the [full setup example](./examples/full).
*
* ## Credit
*
* The Python code that posts the message to Slack was adopted from the [terraform-aws-notify-slack](https://github.com/terraform-aws-modules/terraform-aws-notify-slack) module under the Apache 2.0 license.
*/

resource "aws_lambda_function" "notify_slack" {
  function_name = var.function_name
  description   = "Lambda function to post CloudWatch alarm notifications to a Slack channel."

  filename    = data.archive_file.notify_slack.output_path
  handler     = "notify_slack.lambda_handler"
  runtime     = "python3.8"
  timeout     = 30
  memory_size = 128

  role             = aws_iam_role.notify_slack_lambda.arn
  source_code_hash = filebase64sha256(data.archive_file.notify_slack.output_path)

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
      PROJECT_NAME      = var.project_name
      LOG_EVENTS        = "True"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.notify_slack_lambda,
    aws_cloudwatch_log_group.notify_slack_lambda,
  ]

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
  }
}

data "archive_file" "notify_slack" {
  type        = "zip"
  source_file = "${path.module}/notify_slack/notify_slack.py"
  output_path = "/tmp/notify_slack.py.zip"
}

resource "aws_lambda_permission" "notify_slack" {
  count = length(var.sns_topic_arns)

  statement_id  = "AllowExecutionFromSNS-${var.function_name}-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_slack.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arns[count.index]
}

#
# CloudWatch: Lambda logs
#
resource "aws_cloudwatch_log_group" "notify_slack_lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = "14"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
  }
}
