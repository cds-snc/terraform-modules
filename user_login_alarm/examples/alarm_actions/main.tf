resource "aws_sns_topic" "samwise_success" {
  name = "samwise_success_sns_terratest"
}

resource "aws_sns_topic" "samwise_failure" {
  name = "samwise_failure_sns_terratest"
}

# Create an alarm for one account with a success and failure action
module "alarm_actions" {
  source                = "../../"
  account_names         = ["samwise"]
  namespace             = "terratest"
  log_group_name        = "CloudTrail/Landing-Zone-Logs"
  alarm_actions_success = [aws_sns_topic.samwise_success.arn]
  alarm_actions_failure = [aws_sns_topic.samwise_failure.arn]
  num_attempts          = 5
}
