
variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "ssc_cbrid_tag_key" {
  description = "(Optional, default 'ssc_cbrid') The tag key for the SSC CBRID"
  type        = string
  default     = "ssc_cbrid"
}

variable "ssc_cbrid_tag_value" {
  description = "(Optional) The value of the SSC CBRID tag"
  type        = string
  default     = "22DH"
}

variable "cloudwatch_log_arns" {
  description = "(Optional) A list of CloudWatch log ARNs to forward to Sentinel"
  type        = list(string)
  default     = []
}

variable "customer_id" {
  description = "(Optional, v1 only) Azure log workspace customer ID. Required on the v1 Data Collector API path; leave unset on v2, which authenticates as an Azure identity instead."
  sensitive   = true
  type        = string
  default     = ""
}

variable "event_rule_names" {
  description = "(Optional) List of names for event rules to trigger the lambda"
  type        = list(string)
  default     = []
}

variable "function_name" {
  description = "(Required) Name of the Lambda function."
  type        = string

  validation {
    condition     = length(var.function_name) < 65
    error_message = "The function name must be between 1 and 64 characters in length."
  }

  validation {
    condition     = can(regex("^[A-Za-z][\\w-]{0,63}$", var.function_name))
    error_message = "The function name must only contain alphanumeric, underscore and hyphen characters."
  }
}

variable "layer_arn" {
  description = "(Optional) ARN of the Lambda layer to use. The v2 Logs Ingestion API needs layer version 270 or later."
  default     = "arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:20"
}

variable "log_type" {
  description = "(Optional) The namespace for logs. This only applies if you are sending application logs"
  type        = string
  default     = "ApplicationLog"
}

variable "s3_sources" {
  description = "(Optional) List of s3 buckets to trigger the lambda"
  type = list(object({
    bucket_arn    = string
    bucket_id     = string
    filter_prefix = string
    kms_key_arn   = string
  }))
  default = []
}

variable "shared_key" {
  description = "(Optional, v1 only) Azure log workspace shared secret. Required on the v1 Data Collector API path; leave unset on v2."
  sensitive   = true
  type        = string
  default     = ""
}

#
# v2 — Logs Ingestion API (DCE/DCR)
#
# The layer carries both APIs and picks per-Lambda on the presence of BOTH
# `DCE_ENDPOINT` and `DCR_CONFIG`. A caller that sets neither of the two inputs
# below is on v1 and behaves exactly as before, which is what lets the rollout
# move one consumer at a time rather than as a flag day.
#

variable "dce_endpoint" {
  description = "(Optional, v2) Logs ingestion endpoint of the Azure data collection endpoint. Set together with `dcr_config` to put this forwarder on the Logs Ingestion API; leave both unset to stay on the v1 Data Collector API."
  type        = string
  default     = ""
}

variable "dcr_config" {
  description = "(Optional, v2) Map of the layer's log type to the DCR that accepts it. Feed the `forwarder_v2_aws_dcr_config` output from cds-snc/sentinel verbatim — the attribute names are what the layer reads."
  type = map(object({
    dcrImmutableId = string
    streamName     = string
  }))
  default = {}
}

variable "azure_client_id" {
  description = "(Optional, v2) Client ID of the Azure identity the forwarder authenticates as. Required on both v2 auth paths."
  type        = string
  default     = ""
}

variable "azure_tenant_id" {
  description = "(Optional, v2) Azure tenant ID of that identity. Required on both v2 auth paths."
  type        = string
  default     = ""
}

variable "azure_client_secret" {
  description = "(Optional, v2) Client secret for the Azure identity. Supplying one selects the client-secret auth path and takes precedence over Cognito federation; leave it unset for the secretless path."
  sensitive   = true
  type        = string
  default     = ""
}

variable "cognito_identity_pool_id" {
  description = "(Optional, v2) Cognito identity pool that mints the OIDC assertion, in this Lambda's own AWS account. Set with `cognito_developer_provider_name` for the secretless auth path."
  type        = string
  default     = ""
}

variable "cognito_developer_provider_name" {
  description = "(Optional, v2) Developer provider name on that identity pool. Set with `cognito_identity_pool_id`."
  type        = string
  default     = ""
}
