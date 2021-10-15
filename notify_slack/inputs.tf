variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') Name of the billing tag."
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) Value of the billing tag."
  type        = string
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

variable "project_name" {
  description = "(Required) Name of the project.  This is added to the Slack message's title."
  type        = string
}

variable "slack_webhook_url" {
  description = "(Required) Slack incoming webhook URL.  This determines where the Slack message is posted."
  type        = string
  sensitive   = true
}

variable "sns_topic_arns" {
  description = "(Required) SNS topic ARNs that will invoke the Lambda function and cause a Slack message to be posted."
  type        = list(string)
}
