This module will create an RDS Postgresql Cluster behind an RDS Proxy to manage connections.

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
| [aws_cloudwatch_log_group.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
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
| [aws_security_group.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.rds_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.read_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | This flag allows RDS to perform a major engine upgrade. <br/> **Please Note:** This could break things so make sure you know that your code is compatible with the new features in this version. | `bool` | `false` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | (required) The amount of days to keep backups for. | `number` | n/a | yes |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | (required) The name of the database to be created inside the cluster. | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | (required) The Postgresql database version to use. Engine version is contingent on instance\_class see (this list of supported combinations)[https://docs.amazonaws.cn/en_us/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.SupportAurora] | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The type of EC2 instance to run this on. | `string` | `"db.t3.medium"` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | The number of RDS Cluster instances to create, defaults to HA mode. | `number` | `3` | no |
| <a name="input_name"></a> [name](#input\_name) | (required) The name of the db also used for other identifiers | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | (required) The password for the admin user for the db | `string` | n/a | yes |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | (required) The time you want your DB to be backedup. Takes the format `"07:00-09:00"` | `string` | n/a | yes |
| <a name="input_prevent_cluster_deletion"></a> [prevent\_cluster\_deletion](#input\_prevent\_cluster\_deletion) | This flag prevents deletion of the RDS cluster. <br/> **Please Note:** We cannot prevent deletion of RDS instances in the module, we recommend you add `lifecycle { prevent_deletion = true }` to the module to prevent instance deletion | `bool` | `true` | no |
| <a name="input_proxy_debug_logging"></a> [proxy\_debug\_logging](#input\_proxy\_debug\_logging) | Allows the proxy to log debug information. <br/> **Please Note:** This will include all sql commands and potential sensitive information | `bool` | `false` | no |
| <a name="input_proxy_log_retention_in_days"></a> [proxy\_log\_retention\_in\_days](#input\_proxy\_log\_retention\_in\_days) | The number of days to retain the proxy logs in cloudwatch | `number` | `14` | no |
| <a name="input_sg_ids"></a> [sg\_ids](#input\_sg\_ids) | (required) The security groups this DB is to be attached to | `set(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | (required) The name of the subnet the DB has to stay in | `set(string)` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | (required) The username for the admin user for the db | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (required) The vpc to run the cluster and related infrastructure in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_proxy_connection_string_arn"></a> [proxy\_connection\_string\_arn](#output\_proxy\_connection\_string\_arn) | The arn for the connectionstring to the RDS proxy |
| <a name="output_proxy_connection_string_value"></a> [proxy\_connection\_string\_value](#output\_proxy\_connection\_string\_value) | n/a |
| <a name="output_proxy_endpoint"></a> [proxy\_endpoint](#output\_proxy\_endpoint) | n/a |
| <a name="output_proxy_security_group_arn"></a> [proxy\_security\_group\_arn](#output\_proxy\_security\_group\_arn) | n/a |
| <a name="output_proxy_security_group_id"></a> [proxy\_security\_group\_id](#output\_proxy\_security\_group\_id) | n/a |
