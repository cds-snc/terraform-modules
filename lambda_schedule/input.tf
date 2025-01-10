variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "create_ecr_repository" {
  description = "(Optional, default true) Whether to create an ECR repository for the Lambda image"
  type        = bool
  default     = true
}

variable "lambda_ecr_arn" {
  description = "(Optional, defaults to null) The ARN of the ECR repository containing the Lambda image"
  type        = string
  default     = null
}

variable "lambda_environment_variables" {
  description = "(Optional, defaults to empty map) Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "lambda_image_tag" {
  description = "(Optional, defaults to 'latest') The image tag to use for the Lambda function"
  type        = string
  default     = "latest"
}

variable "lambda_image_uri" {
  description = "(Optional, defaults to null) The URI (and optionally tag) of the Docker image for the Lambda function"
  type        = string
  default     = null
}

variable "lambda_memory" {
  description = "(Optional, default 1024) The memory size for the Lambda function in MB"
  type        = number
  default     = 1024

  validation {
    condition     = var.lambda_memory >= 128 && var.lambda_memory <= 10240
    error_message = "The Lambda memory must be between 128 and 10240 MB"
  }
}

variable "lambda_name" {
  description = "(Required) The name of the Lambda function"
  type        = string
}

variable "lambda_policies" {
  description = "(Optional, default empty list) IAM JSON policies for the Lambda function"
  type        = list(string)
  default     = []
}

variable "lambda_schedule_expression" {
  description = "Schedule expression (cron or rate) for triggering the Lambda"
  type        = string

  validation {
    condition     = can(regex("cron\\(.*\\)|rate\\(.*\\)", var.lambda_schedule_expression))
    error_message = "The schedule expression must be in the format 'cron(*)' or 'rate(*)'"
  }
}

variable "lambda_timeout" {
  description = "(Optional, default 15 seconds) The timeout for the Lambda function in seconds"
  type        = number
  default     = 15

  validation {
    condition     = var.lambda_timeout > 0 && var.lambda_timeout <= 900
    error_message = "The Lambda timeout must be between 1 and 900 seconds"
  }
}

variable "lambda_vpc_config" {
  description = "(Optional, default null) VPC configuration for the Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = {
    subnet_ids         = []
    security_group_ids = []
  }
}

variable "s3_arn_write_path" {
  description = "(Optional, default null) The ARN of the S3 bucket path to allow write access to.  This sould be in the format 'arn:aws:s3:::bucket-name/path/*'"
  type        = string
  default     = null

  validation {
    condition     = var.s3_arn_write_path == null || can(regex("arn:aws:s3:::[^/]+/.*", var.s3_arn_write_path))
    error_message = "The S3 ARN must be in the format 'arn:aws:s3:::bucket-name/path/*'"
  }
}