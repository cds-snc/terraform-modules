###
# Common tags
###
variable "billing_tag_key" {
  description = "(Optional) The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(required) The value of the billing tag"
  type        = string
}

variable "critical_tag_key" {
  description = "(Optional) The name of the critical tag."
  type        = string
  default     = "Critical"
}

variable "critical_tag_value" {
  description = "(Required: default=true) The value of the critical tag. If set to true, protection SCP rules will be applied to the resource."
  type        = bool
  default     = true
}

variable "attach_elb_log_delivery_policy" {
  description = "(Optional: default=false) Controls if S3 bucket should have ELB log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_lb_log_delivery_policy" {
  description = "(Optional: default=false) Controls if S3 bucket should have ALB/NLB log delivery policy attached"
  type        = bool
  default     = false
}

variable "bucket_name" {
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
}

variable "bucket_prefix" {
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "lifecycle_rule" {
  description = "(Optional) List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "object_ownership" {
  description = "(Optional), overrides object ownership value in aws_s3_bucket_ownership_controls. Defaults to BucketOwnerPreferred"
  type        = string
  default     = "BucketOwnerPreferred"
}

variable "versioning_status" {
  description = "(Optional) The versioning status of the bucket.  Valid values are 'Enabled', 'Disabled' or 'Suspended'."
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Enabled", "Disabled", "Suspended"], var.versioning_status)
    error_message = "Versioning status must be 'Enabled', 'Disabled' or 'Suspended'"
  }
}
