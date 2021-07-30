/**
* # User Login Alarm
*
* This module will create two metric filters and two alarms per account passed in through the `account_names` input variable.
* The success alarm will trigger whenever a user successfully logs in through the console. 
* The failure alarm will trigger whenever `num_attempts` failed login attempts occur through the console.
* 
* ## Architecture
*
* ![Diagram of the User Login Alarm](./docs/alarm.png)
*
* ## Things to be aware of
*
* - Cloudtrail is behind by at least fifteen minutes. A lot of damage can be done in that amount of time.
* - We recommend that you don't use Console logins but that you use your Single Sign on to access the AWS Console whenever possible.
*/


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.46.0"
    }
  }
}

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
