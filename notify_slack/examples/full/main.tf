#
# Lambda
#
module "notify_slack" {
  source = "../../"

  function_name     = "notify_slack"
  project_name      = "Terratest"
  slack_webhook_url = "https://your.slack.incoming.webhook.url"

  sns_topic_arns = [aws_sns_topic.warning.arn]

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Terratest"
}

#
# SNS: topic & subscription
#
resource "aws_sns_topic" "warning" {
  # checkov:skip=CKV_AWS_26: encryption not required for example
  name = "warning"
}

resource "aws_sns_topic_subscription" "alert_warning" {
  topic_arn = aws_sns_topic.warning.arn
  protocol  = "lambda"
  endpoint  = module.notify_slack.lambda_arn
}

#
# CloudWatch Alarm: example to monitor concurrent Lambda invocations
#
resource "aws_cloudwatch_metric_alarm" "lambda_concurrent_executions" {
  alarm_name          = "LambdaConcurrentExecutions"
  alarm_description   = "Average number of concurrent Lambda invocations in a 1 minute period."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConcurrentExecutions"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Average"
  threshold           = 100
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.warning.arn]
  ok_actions    = [aws_sns_topic.warning.arn]
}
