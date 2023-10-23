################################################################################
# Cluster
################################################################################
variable "create_cluster" {
  description = "(Optional, default `true`) Determines whether to create a cluster for the service"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "(Required) Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "cloudwatch_log_group_retention_in_days" {
  description = "(Optional, default `30`) Number of days to retain log events"
  type        = number
  default     = 30
}

################################################################################
# Service
################################################################################

variable "desired_count" {
  description = "(Optional, default `1`) The number of instances of the task definition to place and keep running. Defaults to `1`"
  type        = number
  default     = 1
}

variable "service_name" {
  description = "(Required) Name of the service (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
}

variable "platform_version" {
  description = "(Optional, default `LATEST`) Platform version on which to run your service. Defaults to `LATEST`"
  type        = string
  default     = "LATEST"
}

variable "container_name" {
  description = "(Optional, defaults to service_name) The default container name."
  type        = string
  default     = null
}

variable "container_host_port" {
  description = "(Optional, no default) The exposed port of the container used by the load balancer"
  type        = number
  default     = null
}

variable "container_port" {
  description = "(Optional, no default) The port of the service running within the container"
  type        = number
  default     = null
}

variable "enable_execute_command" {
  description = "(Optional, default `false`) Allow for execution of arbitrary commands against the ECS tasks. Defaults to `false`"
  type        = bool
  default     = false
}

variable "lb_target_group_arn" {
  description = "(Optional, no default) The ARN of the load balancer target group.  If this is not provided, no load balancing configuration is set for the service"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "(Required) List of subnets to associate with the service"
  type        = list(string)
}

variable "security_group_ids" {
  description = "(Required) List of security groups to associate with the service"
  type        = list(string)
}

################################################################################
# Autoscaling
################################################################################

variable "enable_autoscaling" {
  description = "(Optional, default `false`) Determines whether to enable autoscaling for the service"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "(Optional, default `1`) Minimum number of tasks to run in your service"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "(Optional, default `2`) Maximum number of tasks to run in your service"
  type        = number
  default     = 2
}

variable "ecs_scale_cpu_threshold" {
  description = "(Optional, default `60`) Cluster CPU use threshold that causes an ECS task scaling event"
  type        = number
  default     = 60
}

variable "ecs_scale_memory_threshold" {
  description = "(Optional, default `60`) Cluster memory use threshold that causes an ECS task scaling event"
  type        = number
  default     = 60
}

variable "ecs_scale_in_cooldown" {
  description = "(Optional, default `60`) Amount of time, in seconds, before another scale-in event can occur"
  type        = number
  default     = 60
}

variable "ecs_scale_out_cooldown" {
  description = "(Optional, default `60`) Amount of time, in seconds, before another scale-out event can occur"
  type        = number
  default     = 60
}

variable "autoscaling_policies" {
  description = "(Optional, scales based on average CPU and memory use) Map of autoscaling policies to create for the service"
  type        = map(any)
  default = {
    cpu = {
      policy_type            = "TargetTrackingScaling"
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    memory = {
      policy_type            = "TargetTrackingScaling"
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

################################################################################
# Container Definition
################################################################################

variable "container_cpu" {
  description = "(Optional, no default) The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of `cpu` of all containers in a task will need to be lower than the task-level cpu value"
  type        = number
  default     = null
}

variable "container_memory" {
  description = "(Optional, no default) The amount (in MiB) of memory to present to the container. If your container attempts to exceed the memory specified here, the container is killed. The total amount of memory reserved for all containers within a task must be lower than the task `memory` value, if one is specified"
  type        = number
  default     = null
}

variable "container_read_only_root_filesystem" {
  description = "(Optional, default `true`) When this parameter is true, the container is given read-only access to its root file system."
  type        = bool
  default     = true
}

variable "container_environment" {
  description = "(Optional, no default) The environment variables to pass to the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "container_essential" {
  description = "(Optional, no default) If the `essential` parameter of a container is marked as `true`, and that container fails or stops for any reason, all other containers that are part of the task are stopped"
  type        = bool
  default     = null
}

variable "container_health_check" {
  description = "(Optional, no default) The container health check command and associated configuration parameters for the container. See [HealthCheck](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html)"
  type        = any
  default     = {}
}


variable "container_image" {
  description = "(Required) The image used to start a container. This string is passed directly to the Docker daemon. By default, images in the Docker Hub registry are available. Other repositories are specified with either `repository-url/image:tag` or `repository-url/image@digest`"
  type        = string
}

variable "container_linux_parameters" {
  description = "(Optional, drop all capabilities) Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more information see [KernelCapabilities](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_KernelCapabilities.html)"
  type        = any
  default = {
    capabilities : {
      drop : ["ALL"]
    }
  }
}

variable "container_secrets" {
  description = "(Optional, no default) The secrets to pass to the container. For more information, see [Specifying Sensitive Data](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html) in the Amazon Elastic Container Service Developer Guide"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

################################################################################
# Task Definition
################################################################################

variable "task_name" {
  description = "(Optional, defaults to the service name) The name of the ECS task"
  type        = string
  default     = null
}

variable "task_cpu" {
  description = "(Required) The number of cpu units used by the task. Consult https://docs.aws.amazon.com/AmazonECS/latest/userguide/fargate-task-defs.html#fargate-tasks-size for valid values"
  type        = number
}

variable "task_memory" {
  description = "(Required) The amount (in MiB) of memory used by the task. Consult https://docs.aws.amazon.com/AmazonECS/latest/userguide/fargate-task-defs.html#fargate-tasks-size for valid values"
  type        = number
}

variable "operating_system_family" {
  description = "(Optional, default `LINUX`) The operating system of the task."
  type        = string
  default     = "LINUX"
}

variable "cpu_architecture" {
  description = "(Optional, default `X86_64`) The CPU architecture of the task. The valid values are `x86_64` and `arm64`"
  type        = string
  default     = "X86_64"
}

variable "task_exec_role_policy_documents" {
  description = "(Optional, default `[]`) A list of IAM policy documents to attach to the task execution role.  Provide this for accessing things needed to initialize ECS tasks like SecretsManager or SSM Parameter Store"
  type        = list(any)
  default     = []
}

variable "task_role_policy_documents" {
  description = "(Optional, default `[]`) A list of IAM policy documents to attach to the task role.  Provide this to provide your app access to other AWS resources at runtime (e.g. S3 or RDS)."
  type        = list(any)
  default     = []
}

################################################################################
# Sentinel
################################################################################

variable "sentinel_customer_id" {
  description = "(Optional, no default) The Sentinel customer ID used to forward logs"
  type        = string
  default     = ""
}

variable "sentinel_forwarder" {
  description = "(Optional, default `false`) Forward ECS cluster logs to Sentinel"
  type        = bool
  default     = false
}

variable "sentinel_fowarder_filter_pattern" {
  description = "(Optional, defaults to sending all logs) The filter pattern of logs to forward to Sentinel"
  type        = string
  default     = "[w1=\"*\"]"
}

variable "sentinel_forwarder_layer_arn" {
  description = "(Optional, default is latest layer ARN) ARN of the Sentinel forwarder lambda layer"
  type        = string
  default     = "arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:97"
}

variable "sentinel_shared_key" {
  description = "(Optional, no default) The Sentinel customer shared key used to forward logs"
  type        = string
  default     = ""
}

################################################################################
# Common
################################################################################

variable "billing_tag_key" {
  description = "(Optional, default `CostCentre`) The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}



