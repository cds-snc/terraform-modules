
variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
  default     = null
}

variable "name" {
  description = "The name of the topic. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the .fifo suffix. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix"
  type        = string
}

variable "name_prefix" {
  description = "(Optional) Creates a unique name beginning with the specified prefix. Conflicts with name"
  type        = string
  default     = null
}

variable "display_name" {
  description = "(Optional) The display name for the topic"
  type        = string
  default     = null
}

variable "policy" {
  description = "(Optional) The fully-formed AWS policy as JSON. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
  type        = string
  default     = null
}

variable "delivery_policy" {
  description = "(Optional) The SNS delivery policy. More on AWS documentation"
  type        = string
  default     = null
}

variable "application_success_feedback_role_arn" {
  description = "(Optional) The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "application_success_feedback_sample_rate" {
  description = "(Optional) Percentage of success to sample"
  type        = number
  default     = null
}

variable "application_failure_feedback_role_arn" {
  description = "(Optional) IAM role for failure feedback"
  type        = string
  default     = null
}

variable "http_success_feedback_role_arn" {
  description = "(Optional) The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "http_success_feedback_sample_rate" {
  description = "(Optional) Percentage of success to sample"
  type        = number
  default     = null
}

variable "http_failure_feedback_role_arn" {
  description = "(Optional) IAM role for failure feedback"
  type        = string
  default     = null
}

variable "kms_master_key_id" {
  description = "(Optional) The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK. For more information, see Key Terms"
  type        = string
  default     = null
}

variable "kms_event_sources" {
  description = "(Optional) List of AWS services that can access the topic."
  type        = list(string)
  default     = []
}

variable "kms_iam_sources" {
  description = "(Optional) List of AWS IAM role sources that can access the topic."
  type        = list(string)
  default     = []
}

variable "fifo_topic" {
  description = "(Optional) Boolean indicating whether or not to create a FIFO (first-in-first-out) topic (default is false)."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "(Optional) Enables content-based deduplication for FIFO topics. For more information, see the related documentation"
  type        = bool
  default     = false
}

variable "lambda_success_feedback_role_arn" {
  description = "(Optional) The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "lambda_success_feedback_sample_rate" {
  description = "(Optional) Percentage of success to sample"
  type        = number
  default     = null
}

variable "lambda_failure_feedback_role_arn" {
  description = "(Optional) IAM role for failure feedback"
  type        = string
  default     = null
}

variable "sqs_success_feedback_role_arn" {
  description = "(Optional) The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "sqs_success_feedback_sample_rate" {
  description = "(Optional) Percentage of success to sample"
  type        = number
  default     = null
}

variable "sqs_failure_feedback_role_arn" {
  description = "(Optional) IAM role for failure feedback"
  type        = string
  default     = null
}

variable "firehose_success_feedback_role_arn" {
  description = "(Optional) The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "firehose_success_feedback_sample_rate" {
  description = "(Optional) Percentage of success to sample"
  type        = number
  default     = null
}

variable "firehose_failure_feedback_role_arn" {
  description = "(Optional) IAM role for failure feedback"
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  type        = map(string)
  default     = {}
}
