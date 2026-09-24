#
# This example forwards CloudWatch logs that match a filter to Sentinel on the
# Logs Ingestion API (v2), with no stored secret. Before applying it with the
# v2 inputs, complete the one-time Cognito setup in the module README: the
# pool below must exist and be trusted by the Azure managed identity first.
#
resource "aws_cognito_identity_pool" "sentinel_forwarder" {
  identity_pool_name               = "sentinel-forwarder"
  allow_unauthenticated_identities = false
  developer_provider_name          = "azure-sentinel-access"
}

module "sentinel_forwarder" {
  source            = "../../"
  function_name     = "sentinel-cloud-watch-forwarder"
  layer_arn         = "arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:270" # 270 or later for v2
  billing_tag_value = "Examples"

  dce_endpoint = var.dce_endpoint
  dcr_config = {
    AWSCloudWatchLog = {
      dcrImmutableId = var.cloudwatch_dcr_immutable_id
      streamName     = "Custom-AWSCloudWatchLog_v2_Input"
    }
  }
  azure_client_id                 = var.azure_client_id
  azure_tenant_id                 = var.azure_tenant_id
  cognito_identity_pool_id        = aws_cognito_identity_pool.sentinel_forwarder.id
  cognito_developer_provider_name = aws_cognito_identity_pool.sentinel_forwarder.developer_provider_name

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
