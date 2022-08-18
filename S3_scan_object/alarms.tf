locals {
  error_logged_lambda = "S3ScanObjectLambdaError${title(var.product_name)}"
}

resource "aws_cloudwatch_log_metric_filter" "scan_files_lambda_error" {
  count = var.alarm_sns_topic_arn != null ? 1 : 0

  name           = local.error_logged_lambda
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.s3_scan_object.name

  metric_transformation {
    name      = local.error_logged_lambda
    namespace = "ScanFiles"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "scan_files_api_error" {
  count = var.alarm_sns_topic_arn != null ? 1 : 0

  alarm_name          = local.error_logged_lambda
  alarm_description   = "Errors logged by the Scan Files transport lambda function"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  metric_name        = aws_cloudwatch_log_metric_filter.scan_files_lambda_error[0].metric_transformation[0].name
  namespace          = aws_cloudwatch_log_metric_filter.scan_files_lambda_error[0].metric_transformation[0].namespace
  period             = "60"
  evaluation_periods = "1"
  statistic          = "Sum"
  threshold          = "1"
  treat_missing_data = "notBreaching"

  alarm_actions = [var.alarm_sns_topic_arn]
  ok_actions    = [var.alarm_sns_topic_arn]
}
