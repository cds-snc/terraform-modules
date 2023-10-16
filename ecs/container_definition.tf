data "aws_region" "current" {}

locals {
  definition = {
    name            = var.container_name != null ? var.container_name : local.task_definition_family
    cpu             = var.container_cpu
    memory          = var.container_memory
    essential       = var.container_essential
    image           = var.container_image
    healthCheck     = length(var.container_health_check) > 0 ? var.container_health_check : null
    linuxParameters = length(var.container_linux_parameters) > 0 ? var.container_linux_parameters : null

    portMappings = var.container_host_port != null && var.container_port != null ? [{
      hostPort : var.container_host_port,
      containerPort : var.container_port,
      protocol : "tcp"
    }] : null

    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-region        = data.aws_region.current.name,
        awslogs-group         = aws_cloudwatch_log_group.this.name,
        awslogs-stream-prefix = "task"
      }
    }

    readonlyRootFilesystem = var.container_read_only_root_filesystem
    environment            = length(var.container_environment) > 0 ? var.container_environment : null
    secrets                = length(var.container_secrets) > 0 ? var.container_secrets : null
  }

  # Strip out all null values, ECS API will provide defaults in place of null/empty values
  container_definition = { for k, v in local.definition : k => v if v != null }
}
