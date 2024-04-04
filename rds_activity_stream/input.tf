variable "activity_log_retention_days" {
  description = "(Optional, default 7) The number of days to retain the activity stream logs in the S3 bucket."
  type        = number
  default     = 7
}

variable "activity_stream_mode" {
  description = "(Optional, default 'async') The activity stream recording mode to enable on the RDS cluster. Valid values are 'sync' or 'async'."
  type        = string
  default     = "async"

  validation {
    condition     = can(regex("^(sync|async)$", var.activity_stream_mode))
    error_message = "The mode must be either 'sync' or 'async'."
  }
}

variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag."
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag."
  type        = string
}

variable "rds_cluster_arn" {
  description = "(Required) The ARN of the RDS cluster to enable the activity stream on."
  type        = string
}

variable "rds_stream_name" {
  description = "(Required) The name that will be used to represent this activity stream's resources.  It must be unique within the account."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.rds_stream_name))
    error_message = "The name must only contain alphanumeric characters and hyphens."
  }
}