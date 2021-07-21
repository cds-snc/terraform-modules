resource "aws_cloudwatch_log_metric_filter" "user_alarm" {
  name           = "${var.account_name}_login"
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.userIdentity.userName = \"${var.account_name}\" }"
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "${var.account_name}_alarm"
    namespace = var.namespace
    value     = 1
  }

}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  alarm_name          = "${aws_cloudwatch_log_metric_filter.user_alarm.name}_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  period              = 10
  metric_name         = aws_cloudwatch_log_metric_filter.user_alarm.name
  namespace           = var.namespace
  statistic           = "Maximum"
  threshold           = 1
  treat_missing_data  = "ignore"
  alarm_actions       = var.alarm_actions
}
