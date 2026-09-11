################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  name              = local.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  tags              = local.common_tags_with_cbrid
}

resource "aws_cloudwatch_log_group" "this_service_connect" {
  count = var.service_connect_enabled ? 1 : 0

  name              = "${local.cloudwatch_log_group_name}-service-connect"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  tags              = local.common_tags_with_cbrid
}

# Forward logs to Sentinel
# Sourced by relative path, not `?ref=main`. A floating ref meant every caller
# of this module resolved the forwarder from main on each init, whatever version
# of `ecs` it had pinned — so a change here reached them without any version
# bump, and pinning `ecs` proved nothing about the forwarder. A relative path
# resolves inside whichever ref of this repository the caller already fetched,
# which is what pinning is supposed to mean.
module "sentinel_forwarder" {
  count             = var.sentinel_forwarder ? 1 : 0
  source            = "../sentinel_forwarder"
  function_name     = substr(var.cluster_name, 0, 64)
  billing_tag_value = var.billing_tag_value

  layer_arn   = var.sentinel_forwarder_layer_arn
  customer_id = var.sentinel_customer_id
  shared_key  = var.sentinel_shared_key

  # Logs Ingestion API (v2). Unset by default, which leaves the forwarder on the
  # v1 Data Collector API exactly as before.
  dce_endpoint                    = var.sentinel_dce_endpoint
  dcr_config                      = var.sentinel_dcr_config
  azure_client_id                 = var.sentinel_azure_client_id
  azure_tenant_id                 = var.sentinel_azure_tenant_id
  azure_client_secret             = var.sentinel_azure_client_secret
  cognito_identity_pool_id        = var.sentinel_cognito_identity_pool_id
  cognito_developer_provider_name = var.sentinel_cognito_developer_provider_name

  cloudwatch_log_arns = [
    aws_cloudwatch_log_group.this.arn,
  ]
}

resource "aws_cloudwatch_log_subscription_filter" "this_sentinel_forwarder" {
  count           = var.sentinel_forwarder ? 1 : 0
  name            = "All cluster logs"
  log_group_name  = aws_cloudwatch_log_group.this.name
  filter_pattern  = var.sentinel_fowarder_filter_pattern
  destination_arn = module.sentinel_forwarder[0].lambda_arn
  distribution    = "Random"
}
