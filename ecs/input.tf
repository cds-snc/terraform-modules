################################################################################
# Cluster
################################################################################
variable "create_cluster" {
  description = "Determines whether to create a cluster for the service"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "cluster_settings" {
  description = "Configuration block(s) with cluster settings."
  type        = map(string)
  default = {
    name  = "containerInsights"
    value = "enabled"
  }
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 90
}

################################################################################
# Service
################################################################################
variable "create_service" {
  description = "Determines whether to create a service for the cluster"
  type        = bool
  default     = true
}

variable "desired_count" {
  description = "The number of instances of the task definition to place and keep running. Defaults to `0`"
  type        = number
  default     = 1
}

variable "name" {
  description = "Name of the service (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = null
}

variable "launch_type" {
  description = "Launch type on which to run your service. The valid values are `EC2`, `FARGATE`, and `EXTERNAL`. Defaults to `FARGATE`"
  type        = string
  default     = "FARGATE"
}

variable "platform_version" {
  description = "Platform version on which to run your service. Only applicable for `launch_type` set to `FARGATE`. Defaults to `LATEST`"
  type        = string
  default     = "LATEST"
}

variable "propagate_tags" {
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are `SERVICE` and `TASK_DEFINITION`. The default value is `SERVICE`"
  type        = string
  default     = "SERVICE"
}

variable "container_name" {
  description = "The default container name."
  type        = string
  default     = "null"
}

variable "container_port" {
  description = "The default port of the container."
  type        = number
  default     = 8000
}

variable "elb_name" {
  description = "The name of the load balancer."
  type        = string
}

variable "lb_target_group_arn" {
  description = "The arn of the load balancer target group."
  type        = string
}

variable "assign_public_ip" {
  description = "Assign a public IP address to the ENI (Fargate launch type only)"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnets to associate with the task or service"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security groups to associate with the task or service"
  type        = list(string)
  default     = []
}

################################################################################
# Autoscaling
################################################################################

variable "enable_autoscaling" {
  description = "Determines whether to enable autoscaling for the service"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks to run in your service"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks to run in your service"
  type        = number
  default     = 2
}

variable "ecs_scale_cpu_threshold" {
  description = "Cluster CPU use threshold that causes an ECS task scaling event"
  type        = number
}

variable "ecs_scale_memory_threshold" {
  description = "Cluster memory use threshold that causes an ECS task scaling event"
  type        = number
}

variable "ecs_scale_in_cooldown" {
  description = "Amount of time, in seconds, before another scale-in event can occur"
  type        = number
}

variable "ecs_scale_out_cooldown" {
  description = "Amount of time, in seconds, before another scale-out event can occur"
  type        = number
}

variable "autoscaling_policies" {
  description = "Map of autoscaling policies to create for the service"
  type        = any
  default = {
    cpu = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
      }
    }
    memory = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
      }
    }
  }
}

################################################################################
# Container Definition
################################################################################
variable "command" {
  description = "The command that's passed to the container"
  type        = list(string)
  default     = []
}

variable "container_cpu" {
  description = "The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of `cpu` of all containers in a task will need to be lower than the task-level cpu value"
  type        = number
  default     = null
}

variable "dependencies" {
  description = "The dependencies defined for container startup and shutdown. A container can contain multiple dependencies. When a dependency is defined for container startup, for container shutdown it is reversed. The condition can be one of START, COMPLETE, SUCCESS or HEALTHY"
  type = list(object({
    condition     = string
    containerName = string
  }))
  default = []
}

variable "disable_networking" {
  description = "When this parameter is true, networking is disabled within the container"
  type        = bool
  default     = null
}

variable "entrypoint" {
  description = "The entry point that is passed to the container"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "The environment variables to pass to the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "environment_files" {
  description = "A list of files containing the environment variables to pass to a container"
  type = list(object({
    value = string
    type  = string
  }))
  default = []
}

variable "essential" {
  description = "If the `essential` parameter of a container is marked as `true`, and that container fails or stops for any reason, all other containers that are part of the task are stopped"
  type        = bool
  default     = null
}

variable "health_check" {
  description = "The container health check command and associated configuration parameters for the container. See [HealthCheck](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html)"
  type        = any
  default     = {}
}

variable "hostname" {
  description = "The hostname to use for your container"
  type        = string
  default     = null
}

variable "image" {
  description = "The image used to start a container. This string is passed directly to the Docker daemon. By default, images in the Docker Hub registry are available. Other repositories are specified with either `repository-url/image:tag` or `repository-url/image@digest`"
  type        = string
  default     = null
}

variable "interactive" {
  description = "When this parameter is `true`, you can deploy containerized applications that require `stdin` or a `tty` to be allocated"
  type        = bool
  default     = false
}

variable "linux_parameters" {
  description = "Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more information see [KernelCapabilities](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_KernelCapabilities.html)"
  type        = any
  default     = {}
}

variable "log_configuration" {
  description = "Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more information see [KernelCapabilities](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_KernelCapabilities.html)"
  type        = any
  default     = {}
}

variable "container_memory" {
  description = "The amount (in MiB) of memory to present to the container. If your container attempts to exceed the memory specified here, the container is killed. The total amount of memory reserved for all containers within a task must be lower than the task `memory` value, if one is specified"
  type        = number
  default     = null
}

variable "memory_reservation" {
  description = "The soft limit (in MiB) of memory to reserve for the container. When system memory is under heavy contention, Docker attempts to keep the container memory to this soft limit. However, your container can consume more memory when it needs to, up to either the hard limit specified with the `memory` parameter (if applicable), or all of the available memory on the container instance"
  type        = number
  default     = null
}

variable "mount_points" {
  description = "The mount points for data volumes in your container"
  type        = list(any)
  default     = []
}

variable "container_name" {
  description = "The name of a container. If you're linking multiple containers together in a task definition, the name of one container can be entered in the links of another container to connect the containers. Up to 255 letters (uppercase and lowercase), numbers, underscores, and hyphens are allowed"
  type        = string
  default     = null
}

variable "port_mappings" {
  description = "The list of port mappings for the container. Port mappings allow containers to access ports on the host container instance to send or receive traffic. For task definitions that use the awsvpc network mode, only specify the containerPort. The hostPort can be left blank or it must be the same value as the containerPort"
  type        = list(any)
  default     = []
}

variable "privileged" {
  description = "When this parameter is true, the container is given elevated privileges on the host container instance (similar to the root user)"
  type        = bool
  default     = false
}

variable "pseudo_terminal" {
  description = "When this parameter is true, a `TTY` is allocated"
  type        = bool
  default     = false
}

variable "secrets" {
  description = "The secrets to pass to the container. For more information, see [Specifying Sensitive Data](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html) in the Amazon Elastic Container Service Developer Guide"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "ulimits" {
  description = "A list of ulimits to set in the container. If a ulimit value is specified in a task definition, it overrides the default values set by Docker"
  type = list(object({
    hardLimit = number
    name      = string
    softLimit = number
  }))
  default = []
}

variable "user" {
  description = "The user to run as inside the container. Can be any of these formats: user, user:group, uid, uid:gid, user:gid, uid:group. The default (null) will use the container's configured `USER` directive or root if not set"
  type        = string
  default     = null
}

variable "volumes_from" {
  description = "Data volumes to mount from another container"
  type        = list(any)
  default     = []
}

variable "working_directory" {
  description = "The working directory to run commands inside the container"
  type        = string
  default     = null
}


################################################################################
# Task Definition
################################################################################
variable "create_task_definition" {
  description = "Determines whether to create a task definition for the service"
  type        = bool
  default     = true
}

variable "cpu" {
  description = "The number of cpu units used by the task. If the `launch_type` is `FARGATE` this field is required and you must use one of the following values, which determines your range of valid values for the `memory` parameter: `256 (.25 vCPU) | 512 (.5 vCPU) | 1024 (1 vCPU) | 2048 (2 vCPU) | 4096 (4 vCPU)`"
  type        = number
  default     = 256
}

variable "task_definition_family" {
  description = "The family name of the task definition"
  type        = string
  default     = null
}

variable "memory" {
  description = "The amount (in MiB) of memory used by the task. If the `launch_type` is `FARGATE` this field is required and you must use one of the following values, which determines your range of valid values for the `cpu` parameter: `512 (0.5 GB), 1024 (1 GB), 2048 (2 GB)`"
  type        = number
  default     = 512
}

variable "requires_compatibilities" {
  description = "A set of launch types required by the task. The valid values are `EC2` and `FARGATE`"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "network_mode" {
  description = "The Docker networking mode to use for the containers in the task. The valid values are `none`, `bridge`, `awsvpc`, and `host`"
  type        = string
  default     = "awsvpc"
}

variable "operating_system" {
  description = "The operating system of the task."
  type        = string
  default     = "LINUX"
}

variable "cpu_architecture" {
  description = "The CPU architecture of the task. The valid values are `x86_64` and `arm64`"
  type        = string
  default     = "x86_64"
}

variable "container_definitions" {
  description = "A map of valid [container definitions](http://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html). Please note that you should only provide values that are part of the container definition document"
  type        = any
  default     = {}
}

variable "container_definition_json" {
  type        = string
  description = <<-EOT
    A string containing a JSON-encoded array of container definitions
    (`"[{ "name": "container1", ... }, { "name": "container2", ... }]"`).
    See [API_ContainerDefinition](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html),
    [cloudposse/terraform-aws-ecs-container-definition](https://github.com/cloudposse/terraform-aws-ecs-container-definition), or
    [ecs_task_definition#container_definitions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#container_definitions)
    EOT
}

################################################################################
# Security Groups
################################################################################
variable "create_security_group" {
  description = "Determines whether to create a security group for the service"
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Name to use on security group created"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "The VPC ID to use for this configuration"
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Description to use on security group created"
  type        = string
  default     = null
}

variable "security_group_rules" {
  description = "Security group rules to add to the security group created"
  type        = any
  default     = {}
}

################################################################################
# Task Execution - IAM Roles
################################################################################
variable "task_exec_iam_role_arn" {
  description = "Existing IAM role ARN"
  type        = string
  default     = null
}
variable "task_exec_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

################################################################################
# Common
################################################################################
variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}



