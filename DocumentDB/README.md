<!-- BEGIN_TF_DOCS -->
# DocumentDB

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
| [aws_docdb_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster) | resource |
| [aws_docdb_cluster_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster_instance) | resource |
| [aws_docdb_cluster_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster_parameter_group) | resource |
| [aws_docdb_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_subnet_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | (Optional, default is `true`). Determines if any cluster modifications are applied immediately, or during the next maintenance window. Note that apply immediately can result in a brief downtime as the cluster reboots. | `bool` | `true` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | (Optional, default is 7). The number of days that you should keep backups for. | `string` | `"7"` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | (Optional, default is `06:00-08:00`). Daily time range that backups execute (UTC time). Default is at 1:00am - 3:00am EST. | `string` | `"06:00-08:00"` | no |
| <a name="input_billing_code"></a> [billing\_code](#input\_billing\_code) | (Required) The value of the billing code tag | `string` | n/a | yes |
| <a name="input_cluster_family"></a> [cluster\_family](#input\_cluster\_family) | (Required, default is `docdb5.0`). The family of the DocumentDB cluster parameter group. More information can be found at https://docs.aws.amazon.com/documentdb/latest/developerguide/cluster_parameter_groups.html | `string` | `"docdb5.0"` | no |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | (Optional, default is 1). The number of DB instances to create in the cluster. The default value is 1. | `string` | `"1"` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | (Required). Name of the database. | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | (Optional). Default tags for all resources | `map(string)` | <pre>{<br/>  "Terraform": "true"<br/>}</pre> | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | (Optional, default is `true`). Prevents the cluster from being deleted and indicates if deletion protection is enabled. | `bool` | `true` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | (Optional, default is `true`). Enables creation of resource. | `bool` | `true` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | (Optional, default is `docdb`). The name of the database engine to be used for this DB cluster. Defaults to `docdb`. Valid values: `docdb`. | `string` | `"docdb"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | (Optional, default is `5.0.0`). The version number of the database engine to use. Note that updating this argument results in an outage. | `string` | `"5.0.0"` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | (Required, default `db.t3.medium`) The instance class to use for the instance For more information on instance classes, refer to https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs. | `string` | `"db.t3.medium"` | no |
| <a name="input_instance_engine"></a> [instance\_engine](#input\_instance\_engine) | (Optional, default is `docdb`). The name of the database engine to be used for the DocumentDB instance. Defaults to `docdb`. Valid values: `docdb`. | `string` | `"docdb"` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | (Optional). The ARN for the KMS encryption key. If you are using a `kms_key_id` then the `storage_encrypted` variable needs to be set to `true`. | `string` | `""` | no |
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | (Required). The password of the documentdb cluster. | `string` | n/a | yes |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | (Required) The username of the documentdb cluster. | `string` | n/a | yes |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | (Optional). List of parameters to apply to the DocumentDB database | <pre>list(object({<br/>    apply_method = optional(string)<br/>    name         = string<br/>    value        = string<br/>  }))</pre> | `[]` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | (Optional). Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot. | `string` | `""` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | (Optional, default is `false`). Determines if the DB cluster is encrypted. | `bool` | `false` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | (Required) List of VPC subnet IDs. | `list(string)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | (Optional). A list of VPC security group IDs to associate with the DocumentDB cluster. | `set(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The document db cluster name |
| <a name="output_docdb_cluster_arn"></a> [docdb\_cluster\_arn](#output\_docdb\_cluster\_arn) | The document db cluster arn |
| <a name="output_docdb_cluster_id"></a> [docdb\_cluster\_id](#output\_docdb\_cluster\_id) | The document db cluster id |
| <a name="output_docdb_endpoint"></a> [docdb\_endpoint](#output\_docdb\_endpoint) | The document db endpoint |
| <a name="output_docdb_port"></a> [docdb\_port](#output\_docdb\_port) | The document db port |
<!-- END_TF_DOCS -->