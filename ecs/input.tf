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

variable "service_name" {
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



