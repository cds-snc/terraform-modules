
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

variable "s3_upload_bucket_create" {
  description = "(Optional, default 'true') Create an S3 bucket to upload files to."
  type        = bool
  default     = true
}

variable "s3_upload_bucket_name" {
  description = "(Optional, default null) Name of the S3 upload bucket to scan objects in.  If `s3_upload_bucket_create` is `false` this must be an existing bucket in the account."
  type        = string
  default     = null

  validation {
    condition     = can(regex("^[0-9a-z\\-\\.]{3,63}$", var.s3_upload_bucket_name))
    error_message = "The S3 bucket name can only container lowercase alphanumeric characters, hyphens, and periods."
  }
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

variable "scan_files_url" {
  description = "(Optional, default Scan Files production URL) Scan Files URL"
  default     = "https://scan-files.alpha.canada.ca"
  type        = string
}
