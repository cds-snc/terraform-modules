resource "aws_cloudwatch_log_metric_filter" "user_alarm" {
  for_each       = var.account_names
  name           = "${each.value}_ConsoleLogin"
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.userIdentity.userName = \"${each.value}\" }"
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "${each.value}_alarm"
    namespace = var.namespace
    value     = 1
  }

}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  for_each            = aws_cloudwatch_log_metric_filter.user_alarm
  alarm_name          = "${each.value.name}_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  period              = 10
  metric_name         = each.value.name
  namespace           = var.namespace
  statistic           = "Maximum"
  threshold           = 1
  treat_missing_data  = "ignore"
  alarm_actions       = var.alarm_actions
}
