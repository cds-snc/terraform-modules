variable "dce_endpoint" {
  description = "Logs ingestion endpoint of the Azure data collection endpoint."
  type        = string
}

variable "cloudwatch_dcr_immutable_id" {
  description = "Immutable id of the DCR that accepts the Custom-AWSCloudWatchLog_v2_Input stream."
  type        = string
}

variable "azure_client_id" {
  description = "Client id of the user-assigned managed identity the forwarder signs in as. Also the developer user identifier used to mint the Cognito identity."
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure tenant id of that identity."
  type        = string
}
