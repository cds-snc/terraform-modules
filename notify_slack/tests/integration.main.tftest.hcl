provider "aws" {
  region = "ca-central-1"
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "default_inputs" {
  command = plan

  variables {
    function_name     = "another-function"
    project_name      = "another-project"
    slack_webhook_url = "https://send-me-slack-messages-now.com"
    sns_topic_arns    = [run.setup.sns_topic_arn]
  }

  assert {
    condition     = aws_lambda_function.notify_slack.function_name == "another-function"
    error_message = "Function name did not match expected value"
  }

  assert {
    condition = aws_lambda_function.notify_slack.environment[0].variables == tomap({
      SLACK_WEBHOOK_URL = "https://send-me-slack-messages-now.com"
      PROJECT_NAME      = "another-project"
      LOG_EVENTS        = "True"
    })
    error_message = "Lambda environment variables do not match expected values"
  }

  assert {
    condition     = length(aws_lambda_permission.notify_slack) == 1
    error_message = "Lambda permission resource count does not match expected value"
  }

  assert {
    condition     = aws_lambda_permission.notify_slack[0].source_arn == run.setup.sns_topic_arn
    error_message = "Lambda permission SNS topic ARN did not match expected value"
  }

  assert {
    condition     = aws_lambda_permission.notify_slack[0].function_name == "another-function"
    error_message = "Lambda permission SNS topic ARN did not match expected value"
  }
}
