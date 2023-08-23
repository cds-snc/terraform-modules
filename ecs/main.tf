/* # Elastic Container Service Cluster (ECS) 
*
* This module creates a pre-configured ECS cluster with a single service and task definition using Fargate. 
*/

data "aws_region" "current" {}

################################################################################
# Cluster
################################################################################

resource "aws_ecs_cluster" "this" {
  count = var.create_cluster ? 1 : 0
  name  = var.cluster_name

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
  count            = var.create_service ? 1 : 0
  name             = var.name
  cluster          = aws_ecs_cluster.this[0].id
  task_definition  = aws_cs_task_definition.this[0].arn
  desired_count    = var.desired_count
  launch_type      = var.launch_type
  platform_version = var.platform_version
  propagate_tags   = var.propagate_tags

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    container_name   = var.container_name
    container_port   = var.container_port
    elb_name         = var.elb_name
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
# Task Definition  
################################################################################
resource "aws_ecs_task_definition" "this" {
  count                    = var.create_task_definition ? 1 : 0
  cpu                      = var.cpu
  execution_role_arn       = var.task_exec_iam_role_arn
  family                   = var.task_definition_family
  memory                   = var.memory
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  task_role_arn            = var.tasks_iam_role_arn
  container_definitions    = local.container_definition

  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }
  tags = merge(local.common_tags, {
    Name = "${var.name}_ecs_task_definition"
  })
}

################################################################################
# Autoscaling
################################################################################
resource "aws_appautoscaling_target" "this" {
  count = var.enable_autoscaling ? 1 : 0

  # Desired needs to be between or equal to min/max
  min_capacity = min(var.autoscaling_min_capacity, var.desired_count)
  max_capacity = max(var.autoscaling_max_capacity, var.desired_count)

  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
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
    target_value = predefined_metric_type == "ECSServiceAverageCPUUtilization" ? var.ecs_scale_cpu_threshold : var.ecs_scale_memory_threshold
  }
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

resource "aws_cloudwatch_log_group" "this_container" {
  count = var.create_cloudwatch_log_group_container && var.enable_cloudwatch_logging ? 1 : 0

  name              = "/aws/ecs/${var.service}/${var.name}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days

  tags = merge(local.common_tags, {
    Name = "${var.name}_container_log_group"
  })
}

#################################################################################
# Security Groups
#################################################################################

resource "aws_security_group" "this" {
  count       = local.create_security_group ? 1 : 0
  name        = local.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.name}_security_group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "this" {
  # Format/Example of the var.security_group_rules variables is:
  # security_group_rules = {
  #     ingress_rule = {
  #       type                     = "ingress"
  #       from_port                = some_container_port
  #       to_port                  = some_container_port
  #       protocol                 = "tcp"
  #       description              = "Service port"
  #       source_security_group_id = some_sg.security_group_id
  #     }
  #     egress_all_rule = {
  #       type        = "egress"
  #       from_port   = 0
  #       to_port     = 0
  #       protocol    = "-1"
  #       cidr_blocks = ["0.0.0.0/0"]
  #     }
  #   }

  for_each = { for k, v in var.security_group_rules : k => v if local.create_security_group }

  # Required
  security_group_id = aws_security_group.this[0].id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type

  # Optional
  description              = lookup(each.value, "description", null)
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  self                     = lookup(each.value, "self", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}
