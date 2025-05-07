################################################################################
# Cluster
################################################################################

output "arn" {
  description = "ARN that identifies the cluster"
  value       = var.create_cluster ? aws_ecs_cluster.this[0].arn : data.aws_ecs_cluster.this[0].arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = var.create_cluster ? aws_ecs_cluster.this[0].id : var.cluster_name
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = var.cluster_name
}

################################################################################
# Service
################################################################################

output "service_id" {
  description = "ARN that identifies the service"
  value       = aws_ecs_service.this.id
}

output "service_name" {
  description = "Name of the service"
  value       = aws_ecs_service.this.name
}

output "service_port" {
  description = "Port of the service"
  value       = var.container_port == null ? "" : var.container_port
}

################################################################################
# Task
################################################################################

output "task_definition_arn" {
  description = "Full ARN of the Task Definition (including both `family` and `revision`)"
  value       = aws_ecs_task_definition.this.arn
}

output "task_definition_revision" {
  description = "Revision of the task in a particular family"
  value       = aws_ecs_task_definition.this.revision
}

output "task_definition_family" {
  description = "The unique name of the task definition"
  value       = aws_ecs_task_definition.this.family
}

output "task_exec_role_arn" {
  description = "ARN of the ECS task execution role (used by ECS to initialize and manage the task)"
  value       = local.task_exec_role_arn
}

output "task_role_arn" {
  description = "ARN of the ECS task role (used by the running task container)"
  value       = local.task_role_arn
}

################################################################################
# CloudWatch Log Group
################################################################################

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = aws_cloudwatch_log_group.this.name
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = aws_cloudwatch_log_group.this.arn
}
