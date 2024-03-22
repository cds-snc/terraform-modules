variable "daily_spend_notifier_hook" {
  type        = string
  description = "(Required) The identifier of the webhook to be used by the spend notifier lambda daily"
  sensitive   = true
}

variable "weekly_spend_notifier_hook" {
  type        = string
  description = "(Required) The identifier of the webhook to be used by the spend notifier lambda weekly"
  sensitive   = true
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
  default     = null
}

variable "account_name" {
  description = "(Required) The name of the account"
  type        = string
  default     = null
}