/* 
* # Elastic Container Service Cluster (ECS)
*
* This module creates a pre-configured ECS cluster with a single service and task definition using Fargate. 
*/

################################################################################
# Cluster
################################################################################

resource "aws_ecs_cluster" "this" {
  count = var.create_cluster ? 1 : 0
  name  = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count        = var.create_cluster ? 1 : 0
  cluster_name = aws_ecs_cluster.this[0].name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

data "aws_ecs_cluster" "this" {
  count        = var.create_cluster ? 0 : 1
  cluster_name = var.cluster_name
}

################################################################################
# Service
################################################################################

resource "aws_ecs_service" "this" {
  name             = var.service_name
  cluster          = var.create_cluster ? aws_ecs_cluster.this[0].name : var.cluster_name
  task_definition  = aws_ecs_task_definition.this.arn
  platform_version = var.platform_version
  launch_type      = "FARGATE"
  propagate_tags   = "SERVICE"

  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = var.lb_target_group_arn != null ? 60 : null
  enable_execute_command             = var.enable_execute_command

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  # Simple load balancer configuration
  dynamic "load_balancer" {
    for_each = var.lb_target_group_arn != null ? [1] : []
    content {
      target_group_arn = var.lb_target_group_arn
      container_name   = local.container_name
      container_port   = var.container_host_port
    }
  }

  # Advanced load balancer configuration
  dynamic "load_balancer" {
    for_each = var.lb_target_group_arns
    content {
      target_group_arn = load_balancer.value.lb_target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_host_port
    }
  }

  dynamic "service_registries" {
    for_each = var.service_discovery_enabled ? [1] : []
    content {
      registry_arn   = aws_service_discovery_service.this[0].arn
      container_name = local.container_name
    }
  }

  lifecycle {
    ignore_changes = [
      desired_count, # Always ignored
    ]
  }

  tags = local.common_tags
}

################################################################################
# Task Definition  
################################################################################

resource "aws_ecs_task_definition" "this" {
  family                = local.task_definition_family
  cpu                   = var.task_cpu
  memory                = var.task_memory
  execution_role_arn    = local.task_exec_role_arn
  task_role_arn         = local.task_role_arn
  container_definitions = jsonencode([local.container_definition])

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }

  dynamic "volume" {
    for_each = var.task_volume != null ? var.task_volume : []
    content {
      name      = volume.value.name
      host_path = volume.value.host_path

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = efs_volume_configuration.value.root_directory
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port

          dynamic "authorization_config" {
            for_each = efs_volume_configuration.value.authorization_config != null ? [efs_volume_configuration.value.authorization_config] : []
            content {
              access_point_id = authorization_config.value.access_point_id
              iam             = authorization_config.value.iam
            }
          }
        }
      }
    }
  }



  tags = local.common_tags
}

################################################################################
# Autoscaling
################################################################################

resource "aws_appautoscaling_target" "this" {
  count = var.enable_autoscaling ? 1 : 0

  # Desired needs to be between or equal to min/max
  min_capacity = min(var.autoscaling_min_capacity, var.desired_count)
  max_capacity = max(var.autoscaling_max_capacity, var.desired_count)

  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = local.common_tags
}

resource "aws_appautoscaling_policy" "this" {
  for_each = { for k, v in var.autoscaling_policies : k => v if var.enable_autoscaling }

  name               = try(each.value.name, each.key)
  policy_type        = try(each.value.policy_type, "TargetTrackingScaling")
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    scale_in_cooldown  = try(var.ecs_scale_in_cooldown, 60)
    scale_out_cooldown = try(var.ecs_scale_out_cooldown, 60)
    predefined_metric_specification {
      predefined_metric_type = try(each.value.predefined_metric_type, null)
      resource_label         = try(each.value.resource_label, null)
    }
    target_value = each.value.predefined_metric_type == "ECSServiceAverageCPUUtilization" ? var.ecs_scale_cpu_threshold : var.ecs_scale_memory_threshold
  }
}
