locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
  }
  container_name         = var.container_name != null ? var.container_name : local.task_definition_family
  task_definition_family = var.task_name != null ? var.task_name : var.service_name
  task_exec_role_arn     = var.task_exec_role_arn != null ? var.task_exec_role_arn : aws_iam_role.this_task_exec.arn
  task_role_arn          = var.task_role_arn != null ? var.task_role_arn : aws_iam_role.this_task.arn
}
