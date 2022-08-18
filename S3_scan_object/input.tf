variable "alarm_on_lambda_error" {
  description = "(Optional) Create CloudWatch alarm if the transport lambda fails.  If `true`, you must also provide `alarm_sns_topic_arn`."
  type        = bool
  default     = false
}

variable "alarm_sns_topic_arn" {
  description = "(Optional) The SNS topic to send transport lambda alarm notifications to."
  type        = string
  default     = ""
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

variable "product_name" {
  description = "(Required) Name of the product using the module"
  type        = string

  validation {
    condition     = can(regex("^[0-9A-Za-z\\-_]+$", var.product_name))
    error_message = "The product name can only container alphanumeric characters, hyphens, and underscores."
  }
}

variable "reserved_concurrent_executions" {
  description = "(Optional, default 10) The number of concurrent executions for the S3 event transport lambda that triggers the start of a scan."
  type        = number
  default     = 10
}

variable "s3_upload_bucket_name" {
  description = "(Required) Name of the existing S3 upload bucket to scan objects in."
  type        = string
}

variable "s3_upload_bucket_policy_create" {
  description = "(Optional, defaut 'true') Create the S3 upload bucket policy to allow Scan Files access."
  type        = bool
  default     = true
}

variable "scan_files_assume_role_create" {
  description = "(Optional, default 'true') Create the IAM role that Scan Files assumes.  Defaults to `true`.  If this is set to `false`, it is assumed that the role already exists in the account."
  type        = bool
  default     = true
}

variable "scan_files_role_arn" {
  description = "(Optional, default Scan Files API role) Scan Files lambda execution role ARN"
  default     = "arn:aws:iam::806545929748:role/scan-files-api"
  type        = string
}

variable "s3_scan_object_function_arn" {
  description = "(Optional, default S3 Scan Object function ARN) S3 scan object lambda function ARN"
  default     = "arn:aws:lambda:ca-central-1:806545929748:function:s3-scan-object"
  type        = string
}

variable "s3_scan_object_role_arn" {
  description = "(Optional, default S3 Scan Object role) S3 scan object lambda execution role ARN"
  default     = "arn:aws:iam::806545929748:role/s3-scan-object"
  type        = string
}
