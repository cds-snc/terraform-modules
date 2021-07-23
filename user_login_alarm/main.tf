resource "aws_cloudwatch_log_metric_filter" "user_alarm_success" {
  for_each       = var.account_names
  name           = "${each.value}_ConsoleLogin_Success"
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.userIdentity.userName = \"${each.value}\" && $.responseElements.ConsoleLogin = \"Success\" }"
  log_group_name = var.log_group_name

  metric_transformation {
    # The name of the metric has to be the same as the filter name otherwise the alarm won't work
    name      = "${each.value}_ConsoleLogin_Success"
    namespace = var.namespace
    value     = 1
    unit      = "Count"
  }

}

resource "aws_cloudwatch_metric_alarm" "alarm_success" {
  for_each            = aws_cloudwatch_log_metric_filter.user_alarm_success
  alarm_name          = "${each.value.name}_alarm_success"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  period              = 300
  metric_name         = each.value.name
  namespace           = var.namespace
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions_success
}

resource "aws_cloudwatch_log_metric_filter" "user_alarm_failure" {
  for_each       = var.account_names
  name           = "${each.value}_ConsoleLogin_Failure"
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.userIdentity.userName = \"${each.value}\" && $.responseElements.ConsoleLogin = \"Failure\" }"
  log_group_name = var.log_group_name

  metric_transformation {
    # The name of the metric has to be the same as the filter name otherwise the alarm won't work
    name      = "${each.value}_ConsoleLogin_Failure"
    namespace = var.namespace
    value     = 1
    unit      = "Count"
  }

}

resource "aws_cloudwatch_metric_alarm" "alarm_failure" {
  for_each            = aws_cloudwatch_log_metric_filter.user_alarm_failure
  alarm_name          = "${each.value.name}_alarm_failure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  period              = 300
  metric_name         = each.value.name
  namespace           = var.namespace
  statistic           = "Sum"
  threshold           = var.num_attempts
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions_failure
}