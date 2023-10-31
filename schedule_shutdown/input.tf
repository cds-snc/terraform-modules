variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "cloudwatch_alarm_arns" {
  description = "(Optional) CloudWatch alarm ARNs to enable/disable."
  type        = list(string)
  default     = []
}

variable "ecs_service_arns" {
  description = "(Optional) ECS service ARNs to scale up/down."
  type        = list(string)
  default     = []
}

variable "lambda_runtime" {
  description = "(Optional, defaults to 3.11) The Python runtime to use for the lambda function."
  type        = string
  default     = "python3.11"
}

variable "rds_cluster_arns" {
  description = "(Optional) RDS cluster ARNs to shutdown and startup."
  type        = list(string)
  default     = []
}

variable "route53_healthcheck_arns" {
  description = "(Optional) Route53 healthcheck ARNs to enable/disable."
  type        = list(string)
  default     = []
}

variable "schedule_startup" {
  description = "(Optional, Monday-Friday at 10am UTC) The schedule expression for when resources should be started."
  type        = string
  default     = "cron(0 10 ? * MON-FRI *)"
}

variable "schedule_shutdown" {
  description = "(Optional, every day at 10pm UTC) The schedule expression for when resources should be stopped."
  type        = string
  default     = "cron(0 22 * * ? *)"
}
