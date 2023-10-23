locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
  }
  container_name         = var.container_name != null ? var.container_name : local.task_definition_family
  task_definition_family = var.task_name != null ? var.task_name : var.service_name
}
