locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
  }
  task_definition_family = var.task_name != null ? var.task_name : var.service_name
}
