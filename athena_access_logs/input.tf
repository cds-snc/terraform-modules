variable "athena_bucket_name" {
  description = "(Required) The name of the S3 bucket Athena will use to hold its data."
  type        = string
}

variable "athena_database_name" {
  description = "(Optional, default `access_logs`) The name Athena database to create."
  type        = string
  default     = "access_logs"
}

variable "athena_workgroup_name" {
  description = "(Optional, default `logs`) The name Athena workgroup to create."
  type        = string
  default     = "logs"
}

variable "billing_tag_key" {
  description = "(Optional, default `CostCentre`) The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "lb_access_log_bucket_name" {
  description = "(Optional, default `null`) S3 bucket name of the load balancer's access logs."
  type        = string
  default     = null
}

variable "lb_access_queries_create" {
  description = "(Optional, default `false`) Create the Athena queries for a load balancer's access logs.  If `true`, you must specify a value for `lb_access_log_bucket_name`."
  type        = bool
  default     = false
}

variable "waf_access_log_bucket_name" {
  description = "(Optional, default `null`) S3 bucket name of the WAF's access logs."
  type        = string
  default     = null
}

variable "waf_access_queries_create" {
  description = "(Optional, default `false`) Create the Athena queries for a WAF ACL's access logs.  If `true`, you must specify a value for `waf_access_log_bucket_name`."
  type        = bool
  default     = false
}
