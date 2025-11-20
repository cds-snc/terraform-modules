# Elastic Container Service Cluster (ECS)

This module creates a pre-configured ECS cluster with a single service and task definition using Fargate.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sentinel_forwarder"></a> [sentinel\_forwarder](#module\_sentinel\_forwarder) | github.com/cds-snc/terraform-modules//sentinel_forwarder | main |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_subscription_filter.this_sentinel_forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.this_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.this_task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.this_task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this_task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_service_discovery_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_ecs_task_definition.this_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_iam_policy_document.this_task_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_task_combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_task_exec_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_task_exec_combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_task_exec_ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_task_exec_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#input\_autoscaling\_max\_capacity) | (Optional, default `2`) Maximum number of tasks to run in your service | `number` | `2` | no |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#input\_autoscaling\_min\_capacity) | (Optional, default `1`) Minimum number of tasks to run in your service | `number` | `1` | no |
| <a name="input_autoscaling_policies"></a> [autoscaling\_policies](#input\_autoscaling\_policies) | (Optional, scales based on average CPU and memory use) Map of autoscaling policies to create for the service | `map(any)` | <pre>{<br/>  "cpu": {<br/>    "policy_type": "TargetTrackingScaling",<br/>    "predefined_metric_type": "ECSServiceAverageCPUUtilization"<br/>  },<br/>  "memory": {<br/>    "policy_type": "TargetTrackingScaling",<br/>    "predefined_metric_type": "ECSServiceAverageMemoryUtilization"<br/>  }<br/>}</pre> | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default `CostCentre`) The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_cloudwatch_log_group_append_service_name"></a> [cloudwatch\_log\_group\_append\_service\_name](#input\_cloudwatch\_log\_group\_append\_service\_name) | (Optional, default `true`) Determines whether to append the service name to the CloudWatch log group name | `bool` | `true` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | (Optional, default `30`) Number of days to retain log events | `number` | `30` | no |
| <a name="input_cluster_capacity_provider"></a> [cluster\_capacity\_provider](#input\_cluster\_capacity\_provider) | (Optional, default `FARGATE`) The capacity provider to use for the ECS cluster. Defaults to `FARGATE` | `string` | `"FARGATE"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | (Required) Name of the cluster (up to 255 letters, numbers, hyphens, and underscores) | `string` | n/a | yes |
| <a name="input_container_command"></a> [container\_command](#input\_container\_command) | (Optional, defaults to []) The container command to use instead of the one specified in the container's Docker image. | `list(string)` | `[]` | no |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | (Optional, no default) The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of `cpu` of all containers in a task will need to be lower than the task-level cpu value | `number` | `0` | no |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | (Optional, no default) Full JSON container definitions to use in addition to the module provided container definition. This allows for the use of init and sidecar containers. | `tuple([any])` | `[]` | no |
| <a name="input_container_depends_on"></a> [container\_depends\_on](#input\_container\_depends\_on) | (Optional, no default) A list of dependencies defined for the default container startup. | <pre>list(object({<br/>    containerName = string<br/>    condition     = string<br/>  }))</pre> | `[]` | no |
| <a name="input_container_environment"></a> [container\_environment](#input\_container\_environment) | (Optional, no default) The environment variables to pass to the container | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_container_essential"></a> [container\_essential](#input\_container\_essential) | (Optional, default `true`) If the `essential` parameter of a container is marked as `true`, and that container fails or stops for any reason, all other containers that are part of the task are stopped | `bool` | `true` | no |
| <a name="input_container_health_check"></a> [container\_health\_check](#input\_container\_health\_check) | (Optional, no default) The container health check command and associated configuration parameters for the container. See [HealthCheck](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html) | `any` | `{}` | no |
| <a name="input_container_host_port"></a> [container\_host\_port](#input\_container\_host\_port) | (Optional, no default) The exposed port of the container used by the load balancer | `number` | `null` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | (Required) The image used to start a container. This string is passed directly to the Docker daemon. By default, images in the Docker Hub registry are available. Other repositories are specified with either `repository-url/image:tag` or `repository-url/image@digest` | `string` | n/a | yes |
| <a name="input_container_linux_parameters"></a> [container\_linux\_parameters](#input\_container\_linux\_parameters) | (Optional, drop all capabilities) Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more information see [KernelCapabilities](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_KernelCapabilities.html) | `any` | <pre>{<br/>  "capabilities": {<br/>    "add": [],<br/>    "drop": [<br/>      "ALL"<br/>    ]<br/>  }<br/>}</pre> | no |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | (Optional, no default) The amount (in MiB) of memory to present to the container. If your container attempts to exceed the memory specified here, the container is killed. The total amount of memory reserved for all containers within a task must be lower than the task `memory` value, if one is specified | `number` | `null` | no |
| <a name="input_container_mount_points"></a> [container\_mount\_points](#input\_container\_mount\_points) | (Optional, no default) The mount points for data volumes in the container | <pre>list(object({<br/>    containerPath = string<br/>    sourceVolume  = string<br/>    readOnly      = bool<br/>  }))</pre> | `[]` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | (Optional, defaults to service\_name) The default container name. | `string` | `null` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | (Optional, no default) The port of the service running within the container | `number` | `null` | no |
| <a name="input_container_read_only_root_filesystem"></a> [container\_read\_only\_root\_filesystem](#input\_container\_read\_only\_root\_filesystem) | (Optional, default `true`) When this parameter is true, the container is given read-only access to its root file system. | `bool` | `true` | no |
| <a name="input_container_secrets"></a> [container\_secrets](#input\_container\_secrets) | (Optional, no default) The secrets to pass to the container. For more information, see [Specifying Sensitive Data](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html) in the Amazon Elastic Container Service Developer Guide | <pre>list(object({<br/>    name      = string<br/>    valueFrom = string<br/>  }))</pre> | `[]` | no |
| <a name="input_container_system_controls"></a> [container\_system\_controls](#input\_container\_system\_controls) | (Optional, no default) A list of namespace kernel parameters to set in the container. | `list(string)` | `[]` | no |
| <a name="input_container_ulimits"></a> [container\_ulimits](#input\_container\_ulimits) | (Optional, no default) The ulimits of the container | <pre>list(object({<br/>    name      = string<br/>    softLimit = number<br/>    hardLimit = number<br/>  }))</pre> | `[]` | no |
| <a name="input_container_volumes_from"></a> [container\_volumes\_from](#input\_container\_volumes\_from) | (Optional, no default) Data volumes to mount from another container. | <pre>list(object({<br/>    sourceContainer = string<br/>    readOnly        = bool<br/>  }))</pre> | `[]` | no |
| <a name="input_cpu_architecture"></a> [cpu\_architecture](#input\_cpu\_architecture) | (Optional, default `X86_64`) The CPU architecture of the task. The valid values are `x86_64` and `arm64` | `string` | `"X86_64"` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | (Optional, default `true`) Determines whether to create a cluster for the service | `bool` | `true` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | (Optional, default `1`) The number of instances of the task definition to place and keep running. Defaults to `1` | `number` | `1` | no |
| <a name="input_ecs_scale_cpu_threshold"></a> [ecs\_scale\_cpu\_threshold](#input\_ecs\_scale\_cpu\_threshold) | (Optional, default `60`) Cluster CPU use threshold that causes an ECS task scaling event | `number` | `60` | no |
| <a name="input_ecs_scale_in_cooldown"></a> [ecs\_scale\_in\_cooldown](#input\_ecs\_scale\_in\_cooldown) | (Optional, default `60`) Amount of time, in seconds, before another scale-in event can occur | `number` | `60` | no |
| <a name="input_ecs_scale_memory_threshold"></a> [ecs\_scale\_memory\_threshold](#input\_ecs\_scale\_memory\_threshold) | (Optional, default `60`) Cluster memory use threshold that causes an ECS task scaling event | `number` | `60` | no |
| <a name="input_ecs_scale_out_cooldown"></a> [ecs\_scale\_out\_cooldown](#input\_ecs\_scale\_out\_cooldown) | (Optional, default `60`) Amount of time, in seconds, before another scale-out event can occur | `number` | `60` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | (Optional, default `false`) Determines whether to enable autoscaling for the service | `bool` | `false` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | (Optional, default `false`) Allow for execution of arbitrary commands against the ECS tasks. Defaults to `false` | `bool` | `false` | no |
| <a name="input_lb_target_group_arn"></a> [lb\_target\_group\_arn](#input\_lb\_target\_group\_arn) | (Optional, no default) The ARN of the load balancer target group.  If this is not provided, no load balancing configuration is set for the service | `string` | `null` | no |
| <a name="input_lb_target_group_arns"></a> [lb\_target\_group\_arns](#input\_lb\_target\_group\_arns) | (Optional, no default) The load\_balancer configuration block.  Use when advanced load balancer configuration is required (e.g. multiple target groups or containers). | <pre>list(object({<br/>    target_group_arn = string<br/>    container_name   = string<br/>    container_port   = number<br/>  }))</pre> | `[]` | no |
| <a name="input_operating_system_family"></a> [operating\_system\_family](#input\_operating\_system\_family) | (Optional, default `LINUX`) The operating system of the task. | `string` | `"LINUX"` | no |
| <a name="input_platform_version"></a> [platform\_version](#input\_platform\_version) | (Optional, default `LATEST`) Platform version on which to run your service. Defaults to `LATEST` | `string` | `"LATEST"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | (Required) List of security groups to associate with the service | `list(string)` | n/a | yes |
| <a name="input_sentinel_customer_id"></a> [sentinel\_customer\_id](#input\_sentinel\_customer\_id) | (Optional, no default) The Sentinel customer ID used to forward logs | `string` | `""` | no |
| <a name="input_sentinel_forwarder"></a> [sentinel\_forwarder](#input\_sentinel\_forwarder) | (Optional, default `false`) Forward ECS cluster logs to Sentinel | `bool` | `false` | no |
| <a name="input_sentinel_forwarder_layer_arn"></a> [sentinel\_forwarder\_layer\_arn](#input\_sentinel\_forwarder\_layer\_arn) | (Optional, default is latest layer ARN) ARN of the Sentinel forwarder lambda layer | `string` | `"arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:97"` | no |
| <a name="input_sentinel_fowarder_filter_pattern"></a> [sentinel\_fowarder\_filter\_pattern](#input\_sentinel\_fowarder\_filter\_pattern) | (Optional, defaults to sending all logs) The filter pattern of logs to forward to Sentinel | `string` | `"[w1=\"*\"]"` | no |
| <a name="input_sentinel_shared_key"></a> [sentinel\_shared\_key](#input\_sentinel\_shared\_key) | (Optional, no default) The Sentinel customer shared key used to forward logs | `string` | `""` | no |
| <a name="input_service_discovery_enabled"></a> [service\_discovery\_enabled](#input\_service\_discovery\_enabled) | (Optional, false) Determines if service discovery should be enabled for the ECS service.  If enabled you must also provide a `service_discovery_namespace_id`. | `bool` | `false` | no |
| <a name="input_service_discovery_namespace_id"></a> [service\_discovery\_namespace\_id](#input\_service\_discovery\_namespace\_id) | (Optional, no default) Service discovery namespace ID to associate with the service.  This will allow the service to be discovered by other services within the namespace. | `string` | `null` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | (Required) Name of the service (up to 255 letters, numbers, hyphens, and underscores) | `string` | n/a | yes |
| <a name="input_service_use_latest_task_def"></a> [service\_use\_latest\_task\_def](#input\_service\_use\_latest\_task\_def) | (Optional, default false) Should the ECS service always use the latest ACTIVE task definition?  Set to `true` if the task definition is managed outside of Terraform (e.g. CI/CD workflow that deploys changes by updating the task definition). | `bool` | `false` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | (Required) List of subnets to associate with the service | `list(string)` | n/a | yes |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | (Required) The number of cpu units used by the task. Consult https://docs.aws.amazon.com/AmazonECS/latest/userguide/fargate-task-defs.html#fargate-tasks-size for valid values | `number` | n/a | yes |
| <a name="input_task_exec_role_arn"></a> [task\_exec\_role\_arn](#input\_task\_exec\_role\_arn) | (Optional, no default) The ARN of the IAM role controlling the task execution. | `string` | `null` | no |
| <a name="input_task_exec_role_policy_documents"></a> [task\_exec\_role\_policy\_documents](#input\_task\_exec\_role\_policy\_documents) | (Optional, default `[]`) A list of IAM policy documents to attach to the task execution role.  Provide this for accessing things needed to initialize ECS tasks like SecretsManager or SSM Parameter Store | `list(any)` | `[]` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | (Required) The amount (in MiB) of memory used by the task. Consult https://docs.aws.amazon.com/AmazonECS/latest/userguide/fargate-task-defs.html#fargate-tasks-size for valid values | `number` | n/a | yes |
| <a name="input_task_name"></a> [task\_name](#input\_task\_name) | (Optional, defaults to the service name) The name of the ECS task | `string` | `null` | no |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | (Optional, no default) The ARN of the IAM role controlling the task. | `string` | `null` | no |
| <a name="input_task_role_policy_documents"></a> [task\_role\_policy\_documents](#input\_task\_role\_policy\_documents) | (Optional, default `[]`) A list of IAM policy documents to attach to the task role.  Provide this to provide your app access to other AWS resources at runtime (e.g. S3 or RDS). | `list(any)` | `[]` | no |
| <a name="input_task_volume"></a> [task\_volume](#input\_task\_volume) | (Optional, no default) The volumes to make available to the task to bind mount. | <pre>list(object({<br/>    name      = string<br/>    host_path = optional(string)<br/>    efs_volume_configuration = optional(object({<br/>      file_system_id          = string<br/>      root_directory          = optional(string)<br/>      transit_encryption      = optional(string)<br/>      transit_encryption_port = optional(number)<br/>      authorization_config = optional(object({<br/>        access_point_id = optional(string)<br/>        iam             = optional(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN that identifies the cluster |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | Arn of cloudwatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of cloudwatch log group created |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID that identifies the cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name that identifies the cluster |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | ARN that identifies the service |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Name of the service |
| <a name="output_service_port"></a> [service\_port](#output\_service\_port) | Port of the service |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | Full ARN of the Task Definition (including both `family` and `revision`) |
| <a name="output_task_definition_family"></a> [task\_definition\_family](#output\_task\_definition\_family) | The unique name of the task definition |
| <a name="output_task_definition_revision"></a> [task\_definition\_revision](#output\_task\_definition\_revision) | Revision of the task in a particular family |
| <a name="output_task_exec_role_arn"></a> [task\_exec\_role\_arn](#output\_task\_exec\_role\_arn) | ARN of the ECS task execution role (used by ECS to initialize and manage the task) |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | ARN of the ECS task role (used by the running task container) |
