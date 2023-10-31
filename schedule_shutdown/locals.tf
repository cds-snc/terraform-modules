
locals {
  is_ecs_arns = length(var.ecs_service_arns) > 0
  is_rds_arns = length(var.rds_cluster_arns) > 0
  lambda_name = "schedule-shutdown"

  schedule = {
    "shutdown" : var.schedule_shutdown,
    "startup" : var.schedule_startup,
  }

  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
}

