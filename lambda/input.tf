
variable "allow_api_gateway_invoke" {
  type        = bool
  description = "(Optional) Allow API Gateway to invoke the lambda"
  default     = false
}

variable "allow_s3_execution" {
  type        = bool
  description = "(Optional) Allow S3 to execute the lambda"
  default     = false
}

variable "api_gateway_source_arn" {
  type        = string
  default     = ""
  description = "(Optional) The api gateway rest point that can call the lambda"
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

variable "bucket" {
  type = object({
    id  = string
    arn = string
  })
  default = {
    id  = ""
    arn = ""
  }
  description = "(Optional) S3 bucket that is triggering the lambda"
}

variable "enable_lambda_insights" {
  type        = bool
  default     = true
  description = "(Optional) Enable Lambda Insights"
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "(Optional) Environment variables to pass to the lambda"
}

variable "image_uri" {
  type        = string
  description = "(Required) Docker image URI"
}

variable "memory" {
  type        = number
  description = "(Optional) Memory in MB"
  default     = 128
}

variable "name" {
  type        = string
  description = "(Required) Name of the lambda"
}

variable "policies" {
  type        = list(string)
  description = "(Optional) List of policies to attach to the Lambda function"
  default     = []
}

variable "sns_topic_arns" {
  type        = list(string)
  description = "(Optional) SNS triggers to attach to the Lambda function"
  default     = []
}

variable "timeout" {
  type        = number
  description = "(Optional) Timeout in seconds"
  default     = 3
}

variable "vpc" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = {
    subnet_ids         = []
    security_group_ids = []
  }
  description = "(Optional) VPC to attach to the Lambda function"
}
