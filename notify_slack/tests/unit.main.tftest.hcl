provider "aws" {
  region = "ca-central-1"
}

run "default_inputs" {
  command = plan

  variables {
    function_name     = "the-function"
    project_name      = "the-project"
    slack_webhook_url = "https://send-me-slack-messages.com"
    sns_topic_arns = [
      "arn:aws:sns:ca-central-1:123456789012:topic-1",
      "arn:aws:sns:ca-central-1:123456789012:topic-2"
    ]
  }

  assert {
    condition     = aws_lambda_function.notify_slack.function_name == "the-function"
    error_message = "Function name did not match expected value"
  }

  assert {
    condition = aws_lambda_function.notify_slack.environment[0].variables == tomap({
      SLACK_WEBHOOK_URL = "https://send-me-slack-messages.com"
      PROJECT_NAME      = "the-project"
      LOG_EVENTS        = "True"
    })
    error_message = "Lambda environment variables do not match expected values"
  }

  assert {
    condition     = length(aws_lambda_permission.notify_slack) == 2
    error_message = "Lambda permission resource count does not match expected value"
  }

  assert {
    condition     = aws_lambda_permission.notify_slack[0].source_arn == "arn:aws:sns:ca-central-1:123456789012:topic-1"
    error_message = "Lambda permission SNS topic ARN did not match expected value"
  }

  assert {
    condition     = aws_lambda_permission.notify_slack[1].source_arn == "arn:aws:sns:ca-central-1:123456789012:topic-2"
    error_message = "Lambda permission SNS topic ARN did not match expected value"
  }
}
