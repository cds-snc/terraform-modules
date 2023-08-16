/* # Elastic Container Service Cluster (ECS) 
*
* This module creates a pre-configured ECS cluster with a single service and task definition using Fargate. 
*/

################################################################################
# Cluster
################################################################################

resource "aws_ecs_cluster" "ecs_cluster" {
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
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "log_group" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = "/aws/ecs/${var.cluster_name}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days

  tags = merge(local.common_tags, {
    Name = "${var.name}_log_group"
  })
}

################################################################################
# Service
################################################################################
resource "aws_ecs_service" "ecs_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  dynamic "network_configuration" {
    for_each = [var.network_configuration]

    content {
      subnets         = network_configuration.value.subnets
      security_groups = network_configuration.value.security_groups
      assign_public_ip = network_configuration.value.assign_public_ip
    }
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}_ecs_service"
  })
}