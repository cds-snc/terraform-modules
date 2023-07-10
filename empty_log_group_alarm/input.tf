
variable "alarm_sns_topic_arn" {
  description = "(Required) The ARN to send the alarm to"
  type        = string
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

variable "log_group_names" {
  description = "(Required) The list of log group names to monitor"
  type        = list(string)
  default     = []
}

variable "time_period_minutes" {
  description = "(Optional, default 5) The time period in minutes to check for incoming logs"
  type        = number
  default     = 5
}

variable "use_anomaly_detection" {
  type    = bool
  default = false
}