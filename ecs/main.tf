/* # Elastic Container Service Cluster (ECS) 
*
* This module creates a pre-configured ECS cluster with a single service and task definition using Fargate. 
*/

################################################################################
# Cluster
################################################################################

resource "aws_ecs_cluster" "this" {
  count = var.create_cluster ? 1 : 0
  name = var.cluster_name

  dynamic "setting" {
    for_each = [var.cluster_settings]

    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}_ecs_cluster"
  })
}


################################################################################
# Service
################################################################################
resource "aws_ecs_service" "this" {
  count           = var.create_service ? 1 : 0
  name            = var.service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type 
  platform_version = var.platform_version
  propagate_tags = var.propagate_tags

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.security_groups
    assign_public_ip = var.assign_public_ip
  }
  
  load_balancer {
    container_name   = var.container_name
    container_port   = var.container_port
    elb_name = var.elb_name
    target_group_arn = var.elb_target_group_arn
  }

   lifecycle {
    ignore_changes = [
      desired_count, # Always ignored
    ]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}_ecs_service"
  })
}

################################################################################
# Autoscaling
################################################################################
resource "aws_appautoscaling_target" "this" {
  count = local.enable_autoscaling ? 1 : 0

  # Desired needs to be between or equal to min/max
  min_capacity = min(var.autoscaling_min_capacity, var.desired_count)
  max_capacity = max(var.autoscaling_max_capacity, var.desired_count)

  resource_id        = "service/${local.cluster_name}/${aws_ecs_service.this[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "this" {
  for_each = { for k, v in var.autoscaling_policies : k => v if local.enable_autoscaling }

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
        target_value = predefined_metric_type == "ECSServiceAverageCPUUtilization" ? var.ecs_scale_cpu_threshold : var.ecs_scale_memory_threshold
    }
}

################################################################################
# Task Definition  
################################################################################
resource "aws_ecs_task_definition" "this" {
  count = var.create_task_definition ? 1 : 0
  cpu   = var.cpu
  execution_role_arn = #TO DO
  family = var.task_definition_family
  memory = var.memory
  network_mode = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  task_role_arn = #TO DO
  container_definitions = #TODO 

  tags = merge(local.common_tags, {
    Name = "${var.name}_ecs_task_definition"
  })
}
################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = "/aws/ecs/${var.cluster_name}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days

  tags = merge(local.common_tags, {
    Name = "${var.name}_log_group"
  })
}

