data "aws_region" "current" {}

locals {
  definition = {
    name            = local.container_name
    command         = length(var.container_command) > 0 ? var.container_command : null
    cpu             = var.container_cpu
    memory          = var.container_memory
    essential       = var.container_essential
    image           = var.container_image
    healthCheck     = length(var.container_health_check) > 0 ? var.container_health_check : null
    linuxParameters = length(var.container_linux_parameters) > 0 ? var.container_linux_parameters : null
    mountPoints     = length(var.container_mount_points) > 0 ? var.container_mount_points : []
    systemControls  = length(var.container_system_controls) > 0 ? var.container_system_controls : []
    volumesFrom     = length(var.container_volumes_from) > 0 ? var.container_volumes_from : []

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
    ulimits                = length(var.container_ulimits) > 0 ? var.container_ulimits : null
    dependsOn              = length(var.container_depends_on) > 0 ? var.container_depends_on : null
  }

  # Strip out all null values, ECS API will provide defaults in place of null/empty values
  container_definition = { for k, v in local.definition : k => v if v != null }
}
