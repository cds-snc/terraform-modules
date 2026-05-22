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

variable "account_names" {
  description = "(required) The account name to alarm on if it's found"
  type        = set(string)
}

variable "namespace" {
  description = "The namespace for the metric"
  type        = string
  default     = "common-metrics"
}

variable "log_group_name" {
  description = "(required) The log group to search for cloudtrail ConsoleLogin events in."
  type        = string
}

variable "alarm_actions_success" {
  description = "(required) The list of actions to execute when this success alarm transitions to alarm state. Takes a set (array) of ARNs"
  type        = set(string)
}

variable "alarm_actions_failure" {
  description = "(required) The list of actions to execute when this failure alarm transitions to alarm state. Takes a set (array) of ARNs"
  type        = set(string)
}

variable "num_attempts" {
  description = "The number of failed attempts to login before the alarm triggers"
  type        = number
  default     = 1
}
