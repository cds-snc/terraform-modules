
This module creates a pre-configured ECS cluster with a single service and task definition using Fargate.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.this_container](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign a public IP address to the ENI (Fargate launch type only) | `bool` | `false` | no |
| <a name="input_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#input\_autoscaling\_max\_capacity) | Maximum number of tasks to run in your service | `number` | `2` | no |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#input\_autoscaling\_min\_capacity) | Minimum number of tasks to run in your service | `number` | `1` | no |
| <a name="input_autoscaling_policies"></a> [autoscaling\_policies](#input\_autoscaling\_policies) | Map of autoscaling policies to create for the service | `any` | <pre>{<br>  "cpu": {<br>    "policy_type": "TargetTrackingScaling",<br>    "target_tracking_scaling_policy_configuration": {<br>      "predefined_metric_specification": {<br>        "predefined_metric_type": "ECSServiceAverageCPUUtilization"<br>      }<br>    }<br>  },<br>  "memory": {<br>    "policy_type": "TargetTrackingScaling",<br>    "target_tracking_scaling_policy_configuration": {<br>      "predefined_metric_specification": {<br>        "predefined_metric_type": "ECSServiceAverageMemoryUtilization"<br>      }<br>    }<br>  }<br>}</pre> | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events | `number` | `90` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster (up to 255 letters, numbers, hyphens, and underscores) | `string` | `""` | no |
| <a name="input_cluster_settings"></a> [cluster\_settings](#input\_cluster\_settings) | Configuration block(s) with cluster settings. | `map(string)` | <pre>{<br>  "name": "containerInsights",<br>  "value": "enabled"<br>}</pre> | no |
| <a name="input_command"></a> [command](#input\_command) | The command that's passed to the container | `list(string)` | `[]` | no |
| <a name="input_container_definition_json"></a> [container\_definition\_json](#input\_container\_definition\_json) | A string containing a JSON-encoded array of container definitions<br>(`"[{ "name": "container1", ... }, { "name": "container2", ... }]"`).<br>See [API\_ContainerDefinition](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html),<br>[cloudposse/terraform-aws-ecs-container-definition](https://github.com/cloudposse/terraform-aws-ecs-container-definition), or<br>[ecs\_task\_definition#container\_definitions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#container_definitions) | `string` | n/a | yes |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | A map of valid [container definitions](http://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html). Please note that you should only provide values that are part of the container definition document | `any` | `{}` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The default container name. | `string` | `"null"` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The default port of the container. | `number` | `8000` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of cpu units used by the task. If the `launch_type` is `FARGATE` this field is required and you must use one of the following values, which determines your range of valid values for the `memory` parameter: `256 (.25 vCPU) | 512 (.5 vCPU) | 1024 (1 vCPU) | 2048 (2 vCPU) | 4096 (4 vCPU)` | `number` | `256` | no |
| <a name="input_cpu_architecture"></a> [cpu\_architecture](#input\_cpu\_architecture) | The CPU architecture of the task. The valid values are `x86_64` and `arm64` | `string` | `"x86_64"` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled | `bool` | `true` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | Determines whether to create a cluster for the service | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Determines whether to create a security group for the service | `bool` | `true` | no |
| <a name="input_create_service"></a> [create\_service](#input\_create\_service) | Determines whether to create a service for the cluster | `bool` | `true` | no |
| <a name="input_create_task_definition"></a> [create\_task\_definition](#input\_create\_task\_definition) | Determines whether to create a task definition for the service | `bool` | `true` | no |
| <a name="input_dependencies"></a> [dependencies](#input\_dependencies) | The dependencies defined for container startup and shutdown. A container can contain multiple dependencies. When a dependency is defined for container startup, for container shutdown it is reversed. The condition can be one of START, COMPLETE, SUCCESS or HEALTHY | <pre>list(object({<br>    condition     = string<br>    containerName = string<br>  }))</pre> | `[]` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of instances of the task definition to place and keep running. Defaults to `0` | `number` | `1` | no |
| <a name="input_disable_networking"></a> [disable\_networking](#input\_disable\_networking) | When this parameter is true, networking is disabled within the container | `bool` | `null` | no |
| <a name="input_ecs_scale_cpu_threshold"></a> [ecs\_scale\_cpu\_threshold](#input\_ecs\_scale\_cpu\_threshold) | Cluster CPU use threshold that causes an ECS task scaling event | `number` | n/a | yes |
| <a name="input_ecs_scale_in_cooldown"></a> [ecs\_scale\_in\_cooldown](#input\_ecs\_scale\_in\_cooldown) | Amount of time, in seconds, before another scale-in event can occur | `number` | n/a | yes |
| <a name="input_ecs_scale_memory_threshold"></a> [ecs\_scale\_memory\_threshold](#input\_ecs\_scale\_memory\_threshold) | Cluster memory use threshold that causes an ECS task scaling event | `number` | n/a | yes |
| <a name="input_ecs_scale_out_cooldown"></a> [ecs\_scale\_out\_cooldown](#input\_ecs\_scale\_out\_cooldown) | Amount of time, in seconds, before another scale-out event can occur | `number` | n/a | yes |
| <a name="input_elb_name"></a> [elb\_name](#input\_elb\_name) | The name of the load balancer. | `string` | n/a | yes |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Determines whether to enable autoscaling for the service | `bool` | `false` | no |
| <a name="input_entrypoint"></a> [entrypoint](#input\_entrypoint) | The entry point that is passed to the container | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment variables to pass to the container | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_environment_files"></a> [environment\_files](#input\_environment\_files) | A list of files containing the environment variables to pass to a container | <pre>list(object({<br>    value = string<br>    type  = string<br>  }))</pre> | `[]` | no |
| <a name="input_essential"></a> [essential](#input\_essential) | If the `essential` parameter of a container is marked as `true`, and that container fails or stops for any reason, all other containers that are part of the task are stopped | `bool` | `null` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | The container health check command and associated configuration parameters for the container. See [HealthCheck](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html) | `any` | `{}` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | The hostname to use for your container | `string` | `null` | no |
| <a name="input_image"></a> [image](#input\_image) | The image used to start a container. This string is passed directly to the Docker daemon. By default, images in the Docker Hub registry are available. Other repositories are specified with either `repository-url/image:tag` or `repository-url/image@digest` | `string` | `null` | no |
| <a name="input_interactive"></a> [interactive](#input\_interactive) | When this parameter is `true`, you can deploy containerized applications that require `stdin` or a `tty` to be allocated | `bool` | `false` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | Launch type on which to run your service. The valid values are `EC2`, `FARGATE`, and `EXTERNAL`. Defaults to `FARGATE` | `string` | `"FARGATE"` | no |
| <a name="input_lb_target_group_arn"></a> [lb\_target\_group\_arn](#input\_lb\_target\_group\_arn) | The arn of the load balancer target group. | `string` | n/a | yes |
| <a name="input_linux_parameters"></a> [linux\_parameters](#input\_linux\_parameters) | Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more information see [KernelCapabilities](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_KernelCapabilities.html) | `any` | `{}` | no |
| <a name="input_log_configuration"></a> [log\_configuration](#input\_log\_configuration) | Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more information see [KernelCapabilities](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_KernelCapabilities.html) | `any` | `{}` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount (in MiB) of memory used by the task. If the `launch_type` is `FARGATE` this field is required and you must use one of the following values, which determines your range of valid values for the `cpu` parameter: `512 (0.5 GB), 1024 (1 GB), 2048 (2 GB)` | `number` | `512` | no |
| <a name="input_memory_reservation"></a> [memory\_reservation](#input\_memory\_reservation) | The soft limit (in MiB) of memory to reserve for the container. When system memory is under heavy contention, Docker attempts to keep the container memory to this soft limit. However, your container can consume more memory when it needs to, up to either the hard limit specified with the `memory` parameter (if applicable), or all of the available memory on the container instance | `number` | `null` | no |
| <a name="input_mount_points"></a> [mount\_points](#input\_mount\_points) | The mount points for data volumes in your container | `list(any)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of a container. If you're linking multiple containers together in a task definition, the name of one container can be entered in the links of another container to connect the containers. Up to 255 letters (uppercase and lowercase), numbers, underscores, and hyphens are allowed | `string` | `null` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | The Docker networking mode to use for the containers in the task. The valid values are `none`, `bridge`, `awsvpc`, and `host` | `string` | `"awsvpc"` | no |
| <a name="input_operating_system"></a> [operating\_system](#input\_operating\_system) | The operating system of the task. | `string` | `"LINUX"` | no |
| <a name="input_platform_version"></a> [platform\_version](#input\_platform\_version) | Platform version on which to run your service. Only applicable for `launch_type` set to `FARGATE`. Defaults to `LATEST` | `string` | `"LATEST"` | no |
| <a name="input_port_mappings"></a> [port\_mappings](#input\_port\_mappings) | The list of port mappings for the container. Port mappings allow containers to access ports on the host container instance to send or receive traffic. For task definitions that use the awsvpc network mode, only specify the containerPort. The hostPort can be left blank or it must be the same value as the containerPort | `list(any)` | `[]` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | When this parameter is true, the container is given elevated privileges on the host container instance (similar to the root user) | `bool` | `false` | no |
| <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags) | Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are `SERVICE` and `TASK_DEFINITION`. The default value is `SERVICE` | `string` | `"SERVICE"` | no |
| <a name="input_pseudo_terminal"></a> [pseudo\_terminal](#input\_pseudo\_terminal) | When this parameter is true, a `TTY` is allocated | `bool` | `false` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | A set of launch types required by the task. The valid values are `EC2` and `FARGATE` | `list(string)` | <pre>[<br>  "FARGATE"<br>]</pre> | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | The secrets to pass to the container. For more information, see [Specifying Sensitive Data](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html) in the Amazon Elastic Container Service Developer Guide | <pre>list(object({<br>    name      = string<br>    valueFrom = string<br>  }))</pre> | `[]` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description to use on security group created | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security groups to associate with the task or service | `list(string)` | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name to use on security group created | `string` | `null` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Security group rules to add to the security group created | `any` | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnets to associate with the task or service | `list(string)` | `[]` | no |
| <a name="input_task_definition_family"></a> [task\_definition\_family](#input\_task\_definition\_family) | The family name of the task definition | `string` | `null` | no |
| <a name="input_task_exec_iam_role_arn"></a> [task\_exec\_iam\_role\_arn](#input\_task\_exec\_iam\_role\_arn) | Existing IAM role ARN | `string` | `null` | no |
| <a name="input_task_exec_iam_role_name"></a> [task\_exec\_iam\_role\_name](#input\_task\_exec\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_ulimits"></a> [ulimits](#input\_ulimits) | A list of ulimits to set in the container. If a ulimit value is specified in a task definition, it overrides the default values set by Docker | <pre>list(object({<br>    hardLimit = number<br>    name      = string<br>    softLimit = number<br>  }))</pre> | `[]` | no |
| <a name="input_user"></a> [user](#input\_user) | The user to run as inside the container. Can be any of these formats: user, user:group, uid, uid:gid, user:gid, uid:group. The default (null) will use the container's configured `USER` directive or root if not set | `string` | `null` | no |
| <a name="input_volumes_from"></a> [volumes\_from](#input\_volumes\_from) | Data volumes to mount from another container | `list(any)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID to use for this configuration | `string` | `null` | no |
| <a name="input_working_directory"></a> [working\_directory](#input\_working\_directory) | The working directory to run commands inside the container | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN that identifies the cluster |
| <a name="output_autoscaling_policies"></a> [autoscaling\_policies](#output\_autoscaling\_policies) | Map of autoscaling policies and their attributes |
| <a name="output_autoscaling_scheduled_actions"></a> [autoscaling\_scheduled\_actions](#output\_autoscaling\_scheduled\_actions) | Map of autoscaling scheduled actions and their attributes |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | Arn of cloudwatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of cloudwatch log group created |
| <a name="output_container_cloudwatch_log_group_arn"></a> [container\_cloudwatch\_log\_group\_arn](#output\_container\_cloudwatch\_log\_group\_arn) | Arn of cloudwatch log group created |
| <a name="output_container_cloudwatch_log_group_name"></a> [container\_cloudwatch\_log\_group\_name](#output\_container\_cloudwatch\_log\_group\_name) | Name of cloudwatch log group created |
| <a name="output_container_definition"></a> [container\_definition](#output\_container\_definition) | Container definition |
| <a name="output_container_definitions"></a> [container\_definitions](#output\_container\_definitions) | Container definitions |
| <a name="output_id"></a> [id](#output\_id) | ARN that identifies the service |
| <a name="output_name"></a> [name](#output\_name) | Name of the service |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | Full ARN of the Task Definition (including both `family` and `revision`) |
| <a name="output_task_definition_family"></a> [task\_definition\_family](#output\_task\_definition\_family) | The unique name of the task definition |
| <a name="output_task_definition_revision"></a> [task\_definition\_revision](#output\_task\_definition\_revision) | Revision of the task in a particular family |
