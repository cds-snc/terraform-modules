################################################################################
# Cluster
################################################################################

output "arn" {
  description = "ARN that identifies the cluster"
  value       = try(aws_ecs_cluster.this[0].arn, null)
}

output "id" {
  description = "ID that identifies the cluster"
  value       = try(aws_ecs_cluster.this[0].id, null)
}

output "name" {
  description = "Name that identifies the cluster"
  value       = try(aws_ecs_cluster.this[0].name, null)
}
################################################################################
# Service
################################################################################

output "id" {
  description = "ARN that identifies the service"
  value       = try(aws_ecs_service.this[0].id, aws_ecs_service.ignore_task_definition[0].id, null)
}

output "name" {
  description = "Name of the service"
  value       = try(aws_ecs_service.this[0].name, aws_ecs_service.ignore_task_definition[0].name, null)
}

################################################################################
# Container Definition
################################################################################

output "container_definition" {
  description = "Container definition"
  value       = local.container_definition
}

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = try(aws_cloudwatch_log_group.this[0].name, null)
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = try(aws_cloudwatch_log_group.this[0].arn, null)
}

output "container_definitions" {
  description = "Container definitions"
  value       = local.container_definition
}

################################################################################
# Task Definition
################################################################################

output "task_definition_arn" {
  description = "Full ARN of the Task Definition (including both `family` and `revision`)"
  value       = try(aws_ecs_task_definition.this[0].arn, null)
}

output "task_definition_revision" {
  description = "Revision of the task in a particular family"
  value       = try(aws_ecs_task_definition.this[0].revision, null)
}

output "task_definition_family" {
  description = "The unique name of the task definition"
  value       = try(aws_ecs_task_definition.this[0].family, null)
}

################################################################################
# CloudWatch Log Group
################################################################################

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = try(aws_cloudwatch_log_group.this[0].name, null)
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = try(aws_cloudwatch_log_group.this[0].arn, null)
}

output "container_cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = try(aws_cloudwatch_log_group.this_container[0].name, null)
}

output "container_cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = try(aws_cloudwatch_log_group.this_container[0].arn, null)
}

################################################################################
# Autoscaling
################################################################################

output "autoscaling_policies" {
  description = "Map of autoscaling policies and their attributes"
  value       = aws_appautoscaling_policy.this
}

output "autoscaling_scheduled_actions" {
  description = "Map of autoscaling scheduled actions and their attributes"
  value       = aws_appautoscaling_scheduled_action.this
}

################################################################################
# Security Group
################################################################################

output "security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = try(aws_security_group.this[0].arn, null)
}

output "security_group_id" {
  description = "ID of the security group"
  value       = try(aws_security_group.this[0].id, null)
}