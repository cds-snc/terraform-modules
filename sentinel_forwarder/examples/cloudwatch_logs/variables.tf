variable "dce_endpoint" {
  description = "Logs ingestion endpoint of the Azure data collection endpoint."
  type        = string
}

variable "cloudwatch_dcr_immutable_id" {
  description = "Immutable id of the DCR that accepts the Custom-AWSCloudWatchLog_v2_Input stream."
  type        = string
}

variable "azure_client_id" {
  description = "Client id of the user-assigned managed identity the forwarder signs in as."
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure tenant id of that identity."
  type        = string
}

variable "hub_role_arn" {
  description = "ARN of the hub role the forwarder assumes to mint its Entra client assertion."
  type        = string
}
