
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

variable "architectures" {
  type        = list(any)
  default     = ["x86_64"]
  description = "(Optional) The architectures that the lambda can run on"
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


variable "dead_letter_queue_arn" {
  type        = string
  default     = ""
  description = "(Optional) The arn of the dead letter queue"
}

variable "ecr_arn" {
  type        = string
  description = "(Optional) The arn of the ecr repository the image resides in the lambda will be given access to pull images and layers from this registry"
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

variable "ephemeral_storage" {
  type        = number
  default     = 512
  description = "(Optional) Set the Lambda function's ephemeral storage to a value between 512MB and 10240MB."

  validation {
    condition     = var.ephemeral_storage >= 512 && var.ephemeral_storage <= 10240
    error_message = "Ephemeral storage must be between 512MB and 10240MB."
  }
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

variable "reserved_concurrent_executions" {
  type        = number
  default     = -1
  description = "(Optional) Amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1. See [Managing Concurrency](https://docs.aws.amazon.com/lambda/latest/dg/concurrent-executions.html)"
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
  description = "(Optional) VPC to attach to the Lambda function <br/> **Please Note if this is set it will also attach the AWSLambdaVPCAccessExecutionRole to the lmabda this will enable creation of VPC ENI's as well as reading and writing to logfiles"
}
