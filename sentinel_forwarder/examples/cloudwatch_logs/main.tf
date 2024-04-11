#
# This example demonstrates how to forward CloudWatch logs that match
# a given filter to Sentinel.
#
module "sentinel_forwarder" {
  source            = "../../"
  function_name     = "sentinel-cloud-watch-forwarder"
  layer_arn         = "arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:125" # Must be the most recent layer version
  billing_tag_value = "Examples"

  customer_id = var.sentinel_customer_id
  shared_key  = var.sentinel_shared_key

  cloudwatch_log_arns = [
    aws_cloudwatch_log_group.app_logs.arn
  ]
}

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/lambda/applogs"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_subscription_filter" "error_filter" {
  name            = "ErrorLogs"
  log_group_name  = aws_cloudwatch_log_group.app_logs.name
  filter_pattern  = "?error ?Error ?ERROR"
  destination_arn = module.sentinel_forwarder.lambda_arn
  distribution    = "Random"
}