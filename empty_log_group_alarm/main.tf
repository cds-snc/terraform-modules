/* 
* # Empty lpg group alarm
*
* This module creates a CloudWatch alarm that triggers when a log group is not receiving the expected amount of 
* data based on the `IncomingLogEvents` metric. The input is a list of log group names ex. ["/aws/lambda/
* my-lambda", "/aws/lambda/my-other-lambda"] as well as the arn of a SNS topic to send the alarm to. The module 
* also incudes the flag `use_anomaly_detection` which will use anomaly detection feature to determine the expected 
* amount of data, otherwise it will alert on log groups that receive 0 `IncomingLogEvents` over the time period. 
*
* Note: AWS anomaly detection works best in very specific, unclear, circumstances.
*
* Example usage:
* ```
* module "empty_log_group_alarm" {
*   source              = "github.com/cds-snc/terraform-modules/empty_log_group_alarm"
*   alarm_sns_topic_arn = "arn:aws:sns:ca-central-1:000000000000:alert"
*   log_group_names     = ["/aws/lambda/foo"]
*   billing_tag_value   = "TagValue"
* }
* ```
*/

resource "aws_cloudwatch_metric_alarm" "empty_log_group_metric_alarm" {
  for_each = { for name in(var.use_anomaly_detection ? [] : var.log_group_names) : name => name }

  alarm_name          = "Empty log group alarm: ${each.key}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "IncomingLogEvents"
  namespace           = "AWS/Logs"
  period              = 60 * var.time_period_minutes
  statistic           = "Sum"
  threshold           = 0

  treat_missing_data = "breaching"

  alarm_description = "Alarm when there are no incoming log events for ${var.time_period_minutes} minutes"

  alarm_actions             = [var.alarm_sns_topic_arn]
  insufficient_data_actions = [var.alarm_sns_topic_arn]
  ok_actions                = [var.alarm_sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "empty_log_group_metric_alarm_using_anomaly_detection" {
  for_each = { for name in(var.use_anomaly_detection ? var.log_group_names : []) : name => name }

  alarm_name          = "Less than expected log group alarm: ${each.key}"
  comparison_operator = "LessThanLowerThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  threshold_metric_id = "ad1"

  alarm_description = "Alarm when there are less than expected incoming log events for ${var.time_period_minutes} minutes"

  metric_query {
    id          = "m1"
    period      = 0
    return_data = true

    metric {
      dimensions  = {}
      metric_name = "IncomingLogEvents"
      namespace   = "AWS/Logs"
      period      = 60 * var.time_period_minutes
      stat        = "Sum"
    }
  }
  metric_query {
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    id          = "ad1"
    label       = "IncomingLogEvents (expected)"
    period      = 0
    return_data = true
  }

  alarm_actions             = [var.alarm_sns_topic_arn]
  insufficient_data_actions = [var.alarm_sns_topic_arn]
  ok_actions                = [var.alarm_sns_topic_arn]
}