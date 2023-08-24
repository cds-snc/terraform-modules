
locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }

  log_configuration = merge(
    { for k, v in {
      logDriver = "awslogs",
      options = {
        awslogs-region        = data.aws_region.current.name,
        awslogs-group         = try(aws_cloudwatch_log_group.this_container[0].name, ""),
        awslogs-stream-prefix = "ecs"
      },
    } : k => v if var.enable_cloudwatch_logging },
    var.log_configuration
  )

  definition = {
    command           = length(var.command) > 0 ? var.command : null
    cpu               = var.container_cpu
    dependsOn         = length(var.dependencies) > 0 ? var.dependencies : null # depends_on is a reserved word
    disableNetworking = var.disable_networking
    entrypoint        = length(var.entrypoint) > 0 ? var.entrypoint : null
    environment       = var.environment
    environmentFiles  = length(var.environment_files) > 0 ? var.environment_files : null
    essential         = var.essential
    healthCheck       = length(var.health_check) > 0 ? var.health_check : null
    hostname          = var.hostname
    image             = var.image
    interactive       = var.interactive
    linuxParameters   = length(var.linux_parameters) > 0 ? var.linux_parameters : null
    logConfiguration  = length(local.log_configuration) > 0 ? local.log_configuration : null
    memory            = var.container_memory
    memoryReservation = var.memory_reservation
    mountPoints       = var.mount_points
    name              = var.name
    portMappings      = var.port_mappings
    privileged        = var.privileged
    pseudoTerminal    = var.pseudo_terminal
    secrets           = length(var.secrets) > 0 ? var.secrets : null
    ulimits           = length(var.ulimits) > 0 ? var.ulimits : null
    user              = var.user
    volumesFrom       = var.volumes_from
    workingDirectory  = var.working_directory
  }

  # Strip out all null values, ECS API will provide defaults in place of null/empty values
  container_definition = { for k, v in local.definition : k => v if v != null }

  create_security_group = var.create_security_group && var.network_mode == "awsvpc"
  security_group_name   = try(coalesce(var.security_group_name, var.name), "")

}
