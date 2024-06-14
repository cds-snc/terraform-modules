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

variable "enable_daily_spend_notification" {
  description = "(Optional) Enable daily spend notification"
  type        = bool
  default     = true
}

variable "enable_weekly_spend_notification" {
  description = "(Optional) Enable weekly spend notification"
  type        = bool
  default     = true
}

variable "weekly_schedule_expression" {
  description = "(Optional) The schedule expression for the weekly spend notification"
  type        = string
  default     = "0 12 ? * SUN *"
}

variable "daily_schedule_expression" {
  description = "(Optional) The schedule expression for the daily spend notification"
  type        = string
  default     = "0 12 * * ? *"
}

