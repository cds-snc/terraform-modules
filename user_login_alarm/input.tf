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

variable "alarm_actions" {
  description = "(required) The list of actions to execute when this alarm transitions to alarm state. Takes a set (array) of ARNs"
  type        = set(string)
}
