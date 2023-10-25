locals {
  is_create_task_exec_role = var.task_exec_role_arn == null
  is_create_task_role      = var.task_role_arn == null

  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
  }
  container_name         = var.container_name != null ? var.container_name : local.task_definition_family
  task_definition_family = var.task_name != null ? var.task_name : var.service_name
}
