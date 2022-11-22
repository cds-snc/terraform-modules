
variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "cloudwatch_log_subscription_arns" {
  description = "(Required) A list of CloudWatch log subscription ARNs to forward to Sentinel"
  type        = list(string)
  default     = []
}

variable "customer_id" {
  description = "(Required) Azure log workspace customer ID"
  sensitive   = true
  type        = string
}

variable "event_rule_names" {
  description = "(Optional) List of names for event rules to trigger the lambda"
  type        = list(string)
  default     = []
}

variable "function_name" {
  description = "(Required) Name of the Lambda function."
  type        = string

  validation {
    condition     = length(var.function_name) < 65
    error_message = "The function name must be between 1 and 64 characters in length."
  }

  validation {
    condition     = can(regex("^[A-Za-z][\\w-]{0,63}$", var.function_name))
    error_message = "The function name must only contain alphanumeric, underscore and hyphen characters."
  }
}

variable "layer_arn" {
  description = "(Optional) ARN of the lambda layer to use"
  default     = "arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:9"
}

variable "log_type" {
  description = "(Optional) The namespace for logs. This only applies if you are sending application logs"
  type        = string
  default     = "ApplicationLog"
}

variable "s3_sources" {
  description = "(Optional) List of s3 buckets to trigger the lambda"
  type = list(object({
    bucket_arn    = string
    bucket_id     = string
    filter_prefix = string
    kms_key_arn   = string
  }))
  default = []
}

variable "shared_key" {
  description = "(Required) Azure log workspace shared secret"
  sensitive   = true
  type        = string
}
