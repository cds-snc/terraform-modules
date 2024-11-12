# RDS Activity Stream

Creates an RDS activity stream that has its events written to an S3 bucket for auditting.  By default the activity stream is [asynchronous to prioritize database performance](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/DBActivityStreams.Overview.html#DBActivityStreams.Overview.sync-mode).

This is accomplished with a Kinesis Firehose that reads from the activity stream and uses a Lambda function to decrypts the records before they are written to the bucket.  The design is based on [a recommended AWS architecture](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/DBActivityStreams.Overview.html#DBActivityStreams.Overview.how-they-work).

⚠ **Note:** Docker is required for the `terraform apply` to download the Lambda function's Python dependencies.  

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_activity_stream_bucket"></a> [activity\_stream\_bucket](#module\_activity\_stream\_bucket) | github.com/cds-snc/terraform-modules//S3 | v9.6.8 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.decrypt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.firehose_activity_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.firehose_activity_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_iam_policy.decrypt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.firehose_activity_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.decrypt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.firehose_activity_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.decrypt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.firehose_activity_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_firehose_delivery_stream.activity_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_kms_key.activity_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_function.decrypt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_layer_version.decrypt_deps](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [aws_lambda_permission.lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_rds_cluster_activity_stream.activity_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_activity_stream) | resource |
| [random_string.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [archive_file.decrypt_code](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.decrypt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.decrypt_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.firehose_activity_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.firehose_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [external_external.decrypt_deps](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activity_log_retention_days"></a> [activity\_log\_retention\_days](#input\_activity\_log\_retention\_days) | (Optional, default 7) The number of days to retain the activity stream logs in the S3 bucket. | `number` | `7` | no |
| <a name="input_activity_stream_mode"></a> [activity\_stream\_mode](#input\_activity\_stream\_mode) | (Optional, default 'async') The activity stream recording mode to enable on the RDS cluster. Valid values are 'sync' or 'async'. | `string` | `"async"` | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag. | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag. | `string` | n/a | yes |
| <a name="input_decrypt_lambda_memory_size"></a> [decrypt\_lambda\_memory\_size](#input\_decrypt\_lambda\_memory\_size) | (Optional, default 1024) The amount of memory in MB that the Lambda function will have available for processing. | `number` | `1024` | no |
| <a name="input_decrypt_lambda_timeout"></a> [decrypt\_lambda\_timeout](#input\_decrypt\_lambda\_timeout) | (Optional, default 10) The maximum amount of time in seconds that the Lambda function will process before timing out. | `number` | `10` | no |
| <a name="input_rds_cluster_arn"></a> [rds\_cluster\_arn](#input\_rds\_cluster\_arn) | (Required) The ARN of the RDS cluster to enable the activity stream on. | `string` | n/a | yes |
| <a name="input_rds_stream_name"></a> [rds\_stream\_name](#input\_rds\_stream\_name) | (Required) The name that will be used to represent this activity stream's resources.  It must be unique within the account. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_decrypt_lambda_arn"></a> [decrypt\_lambda\_arn](#output\_decrypt\_lambda\_arn) | The ARN of the decrypt Lambda function. |
| <a name="output_decrypt_lambda_cloudwatch_log_group_name"></a> [decrypt\_lambda\_cloudwatch\_log\_group\_name](#output\_decrypt\_lambda\_cloudwatch\_log\_group\_name) | The name of the decrypt Lambda function's CloudWatch log group. |
| <a name="output_decrypt_lambda_name"></a> [decrypt\_lambda\_name](#output\_decrypt\_lambda\_name) | The name of the decrypt Lambda function. |
| <a name="output_kinesis_firehose_arn"></a> [kinesis\_firehose\_arn](#output\_kinesis\_firehose\_arn) | The ARN of the Kinesis Firehose that is processing the RDS activity stream events. |
| <a name="output_rds_activity_stream_arn"></a> [rds\_activity\_stream\_arn](#output\_rds\_activity\_stream\_arn) | The ARN of the RDS activity stream. |
| <a name="output_s3_activity_stream_bucket_arn"></a> [s3\_activity\_stream\_bucket\_arn](#output\_s3\_activity\_stream\_bucket\_arn) | The ARN of the S3 bucket that the decrypted activity stream logs are written to. |
| <a name="output_s3_activity_stream_bucket_name"></a> [s3\_activity\_stream\_bucket\_name](#output\_s3\_activity\_stream\_bucket\_name) | The name of the S3 bucket that the decrypted activity stream logs are written to. |
