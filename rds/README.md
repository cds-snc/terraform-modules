This module will create an RDS Cluster with an optional RDS Proxy to manage connections.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.log_exports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_event_subscription.rds_sg_events_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_event_subscription) | resource |
| [aws_db_proxy.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy) | resource |
| [aws_db_proxy_default_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_default_target_group) | resource |
| [aws_db_proxy_target.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_target) | resource |
| [aws_db_subnet_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_policy.read_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.rds_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.read_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_rds_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_secretsmanager_secret.connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.proxy_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.proxy_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.rds_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.rds_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.read_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | (Optional, default 'false') This flag allows RDS to perform a major engine upgrade. <br/> **Please Note:** This could break things so make sure you know that your code is compatible with the new features in this version. | `bool` | `false` | no |
| <a name="input_backtrack_window"></a> [backtrack\_window](#input\_backtrack\_window) | (Optional, defaults to 72 hours) The number of days to retain a backtrack. Set to 0 to disable backtracking.  This is only valid for the `aurora-mysql` engine type. | `number` | `259200` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | (Required) The amount of days to keep backups for. | `number` | n/a | yes |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_cloudwatch_log_exports_retention_in_days"></a> [cloudwatch\_log\_exports\_retention\_in\_days](#input\_cloudwatch\_log\_exports\_retention\_in\_days) | (Optional, default 7) The number of days to store exported database logs in the CloudWatch log group. | `number` | `7` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | (Required) The name of the database to be created inside the cluster. | `string` | n/a | yes |
| <a name="input_db_cluster_parameter_group_name"></a> [db\_cluster\_parameter\_group\_name](#input\_db\_cluster\_parameter\_group\_name) | (Optional, no default) Name of DB cluster parameter group to associate with this DB cluster. | `string` | `null` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | (Optional, default empty list) The database log types to export to CloudWatch. Valid values are `audit`, `error`, `general`, `slowquery`, `postgresql`. | `list(string)` | `[]` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | (Optional, defaults 'aurora-postgresql') The database engine to use. Valid values are 'aurora-postgresql' and 'aurora-mysql' | `string` | `"aurora-postgresql"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | (Required) The database version to use. Engine version is contingent on instance\_class see [this list of supported combinations](https://docs.amazonaws.cn/en_us/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.SupportAurora) | `string` | n/a | yes |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | (Optional, default 'false') Enable IAM database authentication for the RDS cluster. | `bool` | `false` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | (Optional, default 'db.t3.medium') The type of EC2 instance to run this on. | `string` | `"db.t3.medium"` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | (Optional, default '3') The number of RDS Cluster instances to create, defaults to HA mode. | `number` | `3` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the db also used for other identifiers | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | (Required) The password for the admin user for the db | `string` | n/a | yes |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | (Optional, default 'true') This flag enables performance insights for the RDS cluster instances. | `bool` | `true` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | (Required) The time you want your DB to be backedup. Takes the format `"07:00-09:00"` | `string` | n/a | yes |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | (Optional) The UTC time you want your DB to be maintained. Takes the format `"wed:06:00-wed:07:00"` | `string` | `"sun:06:00-sun:07:00"` | no |
| <a name="input_prevent_cluster_deletion"></a> [prevent\_cluster\_deletion](#input\_prevent\_cluster\_deletion) | (Optional, default 'true') This flag prevents deletion of the RDS cluster. <br/> **Please Note:** We cannot prevent deletion of RDS instances in the module, we recommend you add `lifecycle { prevent_deletion = true }` to the module to prevent instance deletion | `bool` | `true` | no |
| <a name="input_proxy_debug_logging"></a> [proxy\_debug\_logging](#input\_proxy\_debug\_logging) | (Optional, default 'false') Allows the proxy to log debug information. <br/> **Please Note:** This will include all sql commands and potential sensitive information | `bool` | `false` | no |
| <a name="input_proxy_log_retention_in_days"></a> [proxy\_log\_retention\_in\_days](#input\_proxy\_log\_retention\_in\_days) | (Optional, default '14') The number of days to retain the proxy logs in cloudwatch | `number` | `14` | no |
| <a name="input_proxy_secret_auth_arns"></a> [proxy\_secret\_auth\_arns](#input\_proxy\_secret\_auth\_arns) | (Optional, default none) A list of secret ARNs that contain authentication credentials for the proxy. View the `aws_secretsmanager_secret_version.connection_string` resource for the secret format. Note that these must be database users that already exist. | `list(string)` | `[]` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | (Optional, default '[]') A list of additional security group IDs to associate with the RDS cluster. | `list(string)` | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | (Optional, default '') The name of the security group to create for the RDS cluster. | `string` | `""` | no |
| <a name="input_security_group_notifications_topic_arn"></a> [security\_group\_notifications\_topic\_arn](#input\_security\_group\_notifications\_topic\_arn) | (Optional) The SNS topic ARN to send notifications about security group changes to. | `string` | `""` | no |
| <a name="input_serverless_max_capacity"></a> [serverless\_max\_capacity](#input\_serverless\_max\_capacity) | (Optional) The maximum capacity of the Aurora serverless cluster (0.5 to 128 in increments of 0.5) | `number` | `0` | no |
| <a name="input_serverless_min_capacity"></a> [serverless\_min\_capacity](#input\_serverless\_min\_capacity) | (Optional) The minimum capacity of the Aurora serverless cluster (0.5 to 128 in increments of 0.5) | `number` | `0` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | (Optional, default 'false') This flag determines if a final database snapshot it taken before the cluster is deleted. | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | (Optional, no default) The name or ARN of the DB cluster snapshot to create the cluster from. | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | (Required) The name of the subnet the DB has to stay in | `set(string)` | n/a | yes |
| <a name="input_upgrade_immediately"></a> [upgrade\_immediately](#input\_upgrade\_immediately) | (Optional, default false) Apply database engine upgrades immediately. | `bool` | `false` | no |
| <a name="input_use_proxy"></a> [use\_proxy](#input\_use\_proxy) | (Optional, default 'true') This flag determines if an RDS proxy should be created for the cluster. | `bool` | `true` | no |
| <a name="input_username"></a> [username](#input\_username) | (Required) The username for the admin user for the db | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) The vpc to run the cluster and related infrastructure in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_security_group_arn"></a> [cluster\_security\_group\_arn](#output\_cluster\_security\_group\_arn) | The RDS cluster security group ID. |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | The RDS cluster security group ID. |
| <a name="output_proxy_connection_string_arn"></a> [proxy\_connection\_string\_arn](#output\_proxy\_connection\_string\_arn) | The ARN for the connection string to the RDS proxy. |
| <a name="output_proxy_connection_string_value"></a> [proxy\_connection\_string\_value](#output\_proxy\_connection\_string\_value) | The string value of the RDS proxy connection string.  This includes the username and password. |
| <a name="output_proxy_endpoint"></a> [proxy\_endpoint](#output\_proxy\_endpoint) | The RDS proxy read/write connection endpoint. |
| <a name="output_proxy_security_group_arn"></a> [proxy\_security\_group\_arn](#output\_proxy\_security\_group\_arn) | The RDS proxy security group ARN. |
| <a name="output_proxy_security_group_id"></a> [proxy\_security\_group\_id](#output\_proxy\_security\_group\_id) | The RDS proxy security group ID. |
| <a name="output_rds_cluster_arn"></a> [rds\_cluster\_arn](#output\_rds\_cluster\_arn) | The ARN of the RDS cluster. |
| <a name="output_rds_cluster_endpoint"></a> [rds\_cluster\_endpoint](#output\_rds\_cluster\_endpoint) | RDS cluster read/write connection endpoint. |
| <a name="output_rds_cluster_id"></a> [rds\_cluster\_id](#output\_rds\_cluster\_id) | The ID of the RDS cluster. |
