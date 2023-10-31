
locals {
  is_ecs_arns = var.ecs_service_arns != []
  is_rds_arns = var.rds_cluster_arns != []
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

