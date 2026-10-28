#
# This example forwards CloudWatch logs that match a filter to Sentinel on the
# Logs Ingestion API (v2), with no stored secret, through a hub role. The hub
# must already exist and be trusted by the Azure managed identity: see "Hub
# setup" in the module README.
#
module "sentinel_forwarder" {
  source            = "../../"
  function_name     = "sentinel-cloud-watch-forwarder"
  layer_arn         = "arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:277" # 273 or later for the hub
  billing_tag_value = "Examples"

  dce_endpoint = var.dce_endpoint
  dcr_config = {
    AWSCloudWatchLog = {
      dcrImmutableId = var.cloudwatch_dcr_immutable_id
      streamName     = "Custom-AWSCloudWatchLog_v2_Input"
    }
  }
  azure_client_id = var.azure_client_id
  azure_tenant_id = var.azure_tenant_id
  hub_role_arn    = var.hub_role_arn

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
