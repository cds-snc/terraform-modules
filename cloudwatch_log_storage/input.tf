variable "athena_workgroup_name" {
  description = "(Optional) The name of the Athena workgroup to use for queries. If not provided, Athena queries will not be created."
  type        = string
  default     = ""
}

variable "athena_database_name" {
  description = "(Optional) The name of the Athena database to use for queries. If not provided, Athena queries will not be created."
  type        = string
  default     = ""
}

variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "cloudwatch_log_group_names" {
  description = "(Required) The names of the CloudWatch log groups to subscribe to"
  type        = list(string)
}

variable "log_expiration_days" {
  description = "(Optional, default 730) The number of days to retain logs in S3 before they are deleted"
  type        = number
  default     = 730
}

variable "product_name" {
  description = "(Required) The name of the product"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.product_name))
    error_message = "The product_name must only contain alphanumeric characters, underscores, and hyphens."
  }
}
