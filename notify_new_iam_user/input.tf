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

variable "function_name" {
  description = "(Optional) Name of the Lambda function."
  type        = string
  default     = "new_iam_user_added"

  validation {
    condition     = length(var.function_name) < 65
    error_message = "The function name must be between 1 and 64 characters in length."
  }

  validation {
    condition     = can(regex("^[A-Za-z][\\w-]{0,63}$", var.function_name))
    error_message = "The function name must only contain alphanumeric, underscore and hyphen characters."
  }
}

variable "sns_topic" {
  description = "(Required, default 'internal-sre-alert') The name of the sns topic to send alerts to"
  type        = string
  default     = "internal-sre-alert"
}

variable "logging_level" {
  description = "The logging level of the lambda function"
  type        = string
  default     = "ERROR"
}

