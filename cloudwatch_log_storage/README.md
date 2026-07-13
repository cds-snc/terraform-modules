# CloudWatch Log Storage

This module creates an S3 bucket for storing CloudWatch logs, a Kinesis Firehose delivery stream to send the logs to S3, and subscription filters for each specified CloudWatch log group to forward all logs to the delivery stream. This allows for long term storage of logs in a cheaper storage medium than CloudWatch.

If an Athena workgroup and database is provided, saved Athena queries will also be created that allow you to create a table and query the logs.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch_log_storage"></a> [cloudwatch\_log\_storage](#module\_cloudwatch\_log\_storage) | github.com/cds-snc/terraform-modules//S3 | v11.4.1 |

## Resources

| Name | Type |
|------|------|
| [aws_athena_named_query.cloudwatch_create_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |
| [aws_athena_named_query.cloudwatch_view_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |
| [aws_cloudwatch_log_subscription_filter.firehose_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_iam_role.cloudwatch_log_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.firehose_cloudwatch_log_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch_log_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.firehose_cloudwatch_log_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kinesis_firehose_delivery_stream.cloudwatch_log_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_iam_policy_document.cloudwatch_log_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch_log_storage_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.firehose_cloudwatch_log_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.firehose_cloudwatch_log_storage_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_athena_database_name"></a> [athena\_database\_name](#input\_athena\_database\_name) | (Optional) The name of the Athena database to use for queries. If not provided, Athena queries will not be created. | `string` | `""` | no |
| <a name="input_athena_workgroup_name"></a> [athena\_workgroup\_name](#input\_athena\_workgroup\_name) | (Optional) The name of the Athena workgroup to use for queries. If not provided, Athena queries will not be created. | `string` | `""` | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_cloudwatch_log_group_names"></a> [cloudwatch\_log\_group\_names](#input\_cloudwatch\_log\_group\_names) | (Required) The names of the CloudWatch log groups to subscribe to | `list(string)` | n/a | yes |
| <a name="input_log_expiration_days"></a> [log\_expiration\_days](#input\_log\_expiration\_days) | (Optional, default 730) The number of days to retain logs in S3 before they are deleted | `number` | `730` | no |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | (Required) The name of the product | `string` | n/a | yes |

## Outputs

No outputs.
