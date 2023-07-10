/* # empty_log_group_alarm
* This module creates a CloudWatch alarm that triggers when a log group is not receiving the expected amount of 
* data based on the `IncomingLogEvents` metric. The input is a list of log group names ex. ["/aws/lambda/
* my-lambda", "/aws/lambda/my-other-lambda"] as well as the arn of a SNS topic to send the alarm to. The module 
* also incudes the flag `use_anomaly_detection` which will use anomaly detection feature to determine the expected 
* amount of data, otherwise it will alert on log groups that receive 0 `IncomingLogEvents` over the time period.
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.46.0"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "empty_log_group_metric_alarm" {
  for_each = { for name in var.log_group_names : name => name }

  alarm_name          = "Empty log group alarm: ${each.key}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "IncomingLogEvents"
  namespace           = "AWS/Logs"
  period              = 60 * var.time_period_minutes
  statistic           = "Sum"
  threshold           = 0

  alarm_description = "Alarm when there are no incoming log events for ${var.time_period_minutes} minutes"

  alarm_actions             = [var.alarm_sns_topic_arn]
  insufficient_data_actions = [var.alarm_sns_topic_arn]
  ok_actions                = [var.alarm_sns_topic_arn]
}