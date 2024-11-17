variable "athena_database_name" {
  description = "(Optional, default 'access_logs') The name of the Athena database where the WAF logs table exists."
  type        = string
  default     = "access_logs"
}

variable "athena_query_results_bucket" {
  description = "(Required) The name of the S3 bucket where the Athena query results are stored."
  type        = string
}

variable "athena_query_source_bucket" {
  description = "(Required) The name of the S3 bucket where the source data for the Athena query lives."
  type        = string
}

variable "athena_lb_table_name" {
  description = "(Optional, default 'lb_logs') The name of the Load Balancer logs table in the Athena database."
  type        = string
  default     = "lb_logs"
}

variable "athena_waf_table_name" {
  description = "(Optional, default 'waf_logs') The name of the WAF logs table in the Athena database."
  type        = string
  default     = "waf_logs"
}

variable "athena_workgroup_name" {
  description = "(Optional, default 'primary') The name of the Athena workgroup."
  type        = string
  default     = "primary"
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

variable "query_lb" {
  description = "(Optional, default true) Should the Load Balancer logs be queried for 4xx responses?"
  type        = bool
  default     = true
}

variable "query_waf" {
  description = "(Optional, default true) Should the WAF logs be queried for BLOCK responses?"
  type        = bool
  default     = true
}

variable "service_name" {
  description = "(Required) The name of the service"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-_]*$", var.service_name))
    error_message = "The service name must only contain alphanumeric characters, dashes and underscores."
  }
}

variable "waf_block_threshold" {
  description = "(Optional, default 20) The threshold of blocked requests for adding an IP address to the blocklist"
  type        = number
  default     = 20
}

variable "waf_ip_blocklist_update_schedule" {
  description = "(Optional, default 'rate(2 hours)') The schedule expression for updating the WAF IP blocklist"
  type        = string
  default     = "rate(2 hours)"
}

variable "waf_rule_ids_skip" {
  description = "(Optional, default []) A list of WAF rule IDs to ignore when adding an IP address to the blocklist"
  type        = list(string)
  default     = []
}

variable "waf_scope" {
  description = "(Optional, default 'REGIONAL') The scope of the WAF IP blocklist"
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = can(regex("REGIONAL|CLOUDFRONT", var.waf_scope))
    error_message = "The WAF scope must be either REGIONAL or CLOUDFRONT."
  }
}
