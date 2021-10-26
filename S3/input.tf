###
# Common tags
###
variable "billing_tag_key" {
  description = "(Optional) The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Rquired) The value of the billing tag"
  type        = string
}

variable "block_public_acls" {
  description = "(Optional, default 'true') Reject requests to create public ACLs."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "(Optional, default 'true') Reject requests to add Bucket policy if the specified bucket policy allows public access."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "(Optional, default 'true') Ignore public ACLs on this bucket and any objects that it contains."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "(Optional, default 'true') Only the bucket owner and AWS Services can access this buckets if it has a public policy."
  type        = bool
  default     = true
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

variable "versioning" {
  description = "(Optional) Map containing versioning configuration."
  type        = map(string)
  default     = {}
}

variable "logging" {
  description = "(Optional) Map containing access bucket logging configuration. </br> **target_bucket**: name of the bucket to log to. </br> **target_prefix**: prefix to use when logging"
  type        = map(string)
  default     = {}
}

variable "lifecycle_rule" {
  description = "(Optional) List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "object_lock_configuration" {
  description = "(Optional, Forces new resource) Map containing S3 object locking configuration."
  type        = any
  default     = {}
}
