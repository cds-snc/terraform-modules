
locals {
  common_tags = merge(
    {
      (var.billing_tag_key) = var.billing_tag_value
      Terraform             = "true"
    },
    var.ssc_cbrid_tag_value != "" ? { (var.ssc_cbrid_tag_key) = var.ssc_cbrid_tag_value } : {}
  )

  # Mirrors the layer's own v2_enabled(): it routes to the Logs Ingestion API
  # only when BOTH variables are present, so a half-configured forwarder stays
  # silently on v1. The precondition in main.tf refuses that state rather than
  # letting it ship.
  v2_enabled = var.dce_endpoint != "" && length(var.dcr_config) > 0

  # Only these three are secrets. Everything else v2 needs is configuration and
  # rides as a plain Lambda environment variable, where it is visible in the
  # console and in a plan.
  #
  # Sorted keys, because the SSM body is positional text the wrapper splits on
  # newlines — an unordered map would rewrite the parameter on every apply.
  secrets = merge(
    var.customer_id != "" ? { CUSTOMER_ID = var.customer_id } : {},
    var.shared_key != "" ? { SHARED_KEY = var.shared_key } : {},
    var.azure_client_secret != "" ? { AZURE_CLIENT_SECRET = var.azure_client_secret } : {},
  )
  has_secrets  = length(local.secrets) > 0
  secrets_body = join("\n", [for key in sort(keys(local.secrets)) : "${key}=${local.secrets[key]}"])

  # Pools carry no resource policy, so one cannot be called cross-account: the
  # pool is always in this Lambda's own account and the ARN follows from it.
  cognito_pool_arn = var.cognito_identity_pool_id == "" ? "" : "arn:aws:cognito-identity:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identitypool/${var.cognito_identity_pool_id}"

  # Every variable is omitted rather than set empty. The layer and the wrapper
  # both test presence, not value, so an empty string would read as configured.
  lambda_environment = merge(
    {
      LOG_TYPE = var.log_type
    },
    local.has_secrets ? { SENTINEL_AUTH_PARAMS_ARN = aws_ssm_parameter.sentinel_forwarder_auth[0].arn } : {},
    var.dce_endpoint != "" ? { DCE_ENDPOINT = var.dce_endpoint } : {},
    length(var.dcr_config) > 0 ? { DCR_CONFIG = jsonencode(var.dcr_config) } : {},
    var.azure_client_id != "" ? { AZURE_CLIENT_ID = var.azure_client_id } : {},
    var.azure_tenant_id != "" ? { AZURE_TENANT_ID = var.azure_tenant_id } : {},
    var.cognito_identity_pool_id != "" ? { COGNITO_IDENTITY_POOL_ID = var.cognito_identity_pool_id } : {},
    var.cognito_developer_provider_name != "" ? { COGNITO_DEVELOPER_PROVIDER_NAME = var.cognito_developer_provider_name } : {},
  )
}
