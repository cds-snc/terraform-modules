variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}

variable "workspace_name" {
  description = "The name of the Log Analytics Workspace."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "retention_in_days" {
  description = "The number of days to retain data in the Log Analytics Workspace."
  type        = number
  default     = 120
}

variable "enable_log_analytics_lock" {
  description = "Whether to enable a lock on the Log Analytics Workspace."
  type        = bool
  default     = true
}
