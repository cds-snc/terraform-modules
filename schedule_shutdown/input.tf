variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "ecs_service_arns" {
  description = "(Optional) ECS service ARNs to scale down to zero."
  type        = list(string)
  default     = []
}

variable "rds_cluster_arns" {
  description = "(Optional) RDS cluster ARNs to shutdown and startup."
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
