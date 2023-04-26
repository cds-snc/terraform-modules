variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "sns_topic" {
  description = "(Optional, default 'internal-sre-alert') The name of the sns topic to send alerts to"
  type        = string
  default     = "internal-sre-alert"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "function_name" {
  description = "(Required) Name of the Lambda function."
  type        = string
  default     = "security_group_change_auto_response"

  validation {
    condition     = length(var.function_name) < 65
    error_message = "The function name must be between 1 and 64 characters in length."
  }

  validation {
    condition     = can(regex("^[A-Za-z][\\w-]{0,63}$", var.function_name))
    error_message = "The function name must only contain alphanumeric, underscore and hyphen characters."
  }
}
