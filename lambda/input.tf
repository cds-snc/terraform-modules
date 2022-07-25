
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
  description = <<EOF
  (Optional) The bucket that will be used to trigger the lambda, as defined below.
  (Optional) id - The ID of the bucket.

  (Optional) arn - The Arn of the bucket
  EOF
}


variable "dead_letter_queue_arn" {
  type        = string
  default     = ""
  description = "(Optional) The arn of the dead letter queue"
}

variable "ecr_arn" {
  type        = string
  description = <<EOF
    (Optional) The arn of the ecr repository the image resides in.
    The lambda will be given access to pull images and layers from this registry
  EOF
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

variable "reserved_concurrent_executions" {
  type        = number
  default     = -1
  description = <<EOF
  (Optional) Amount of reserved concurrent executions for this lambda function.
  0 disables lambda from being triggered and,
  1 removes any concurrency limitations

  See [Managing Concurrency](https://docs.aws.amazon.com/lambda/latest/dg/concurrent-executions.html)
  EOF
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
  description = <<EOF
  (Optional) VPC to attach to the Lambda function
  **Please Note** if this is set it will also attach the AWSLambdaVPCAccessExecutionRole to the lmabda.
  This will enable creation of VPC ENI's as well as reading and writing to logfiles
  EOF
}
