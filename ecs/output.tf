################################################################################
# Cluster
################################################################################

output "arn" {
  description = "ARN that identifies the cluster"
  value       = try(aws_ecs_cluster.this[0].arn, null)
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = try(aws_ecs_cluster.this[0].id, null)
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = try(aws_ecs_cluster.this[0].name, null)
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

################################################################################
# Task Definition
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
