# Lambda schedule

Runs a Lambda function on a schedule using an AWS CloudWatch event rule.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_this"></a> [this](#module\_this) | github.com/cds-snc/terraform-modules//lambda | v10.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_iam_policy_document.s3_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_lambda_ecr_arn"></a> [lambda\_ecr\_arn](#input\_lambda\_ecr\_arn) | (Required) The ARN of the ECR repository containing the Lambda image | `string` | n/a | yes |
| <a name="input_lambda_environment_variables"></a> [lambda\_environment\_variables](#input\_lambda\_environment\_variables) | (Optional, default {}) Environment variables for the Lambda function | `map(string)` | `{}` | no |
| <a name="input_lambda_image_uri"></a> [lambda\_image\_uri](#input\_lambda\_image\_uri) | (Required) The URI (and optionally tag) of the Docker image for the Lambda function | `string` | n/a | yes |
| <a name="input_lambda_memory"></a> [lambda\_memory](#input\_lambda\_memory) | (Optional, default 1024) The memory size for the Lambda function in MB | `number` | `1024` | no |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | (Required) The name of the Lambda function | `string` | n/a | yes |
| <a name="input_lambda_schedule_expression"></a> [lambda\_schedule\_expression](#input\_lambda\_schedule\_expression) | Schedule expression (cron or rate) for triggering the Lambda | `string` | n/a | yes |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | (Optional, default 15 seconds) The timeout for the Lambda function in seconds | `number` | `15` | no |
| <a name="input_lambda_vpc_config"></a> [lambda\_vpc\_config](#input\_lambda\_vpc\_config) | (Optional, default null) VPC configuration for the Lambda function | <pre>object({<br/>    subnet_ids         = list(string)<br/>    security_group_ids = list(string)<br/>  })</pre> | `null` | no |
| <a name="input_s3_arn_write_path"></a> [s3\_arn\_write\_path](#input\_s3\_arn\_write\_path) | (Optional, default null) The ARN of the S3 bucket path to allow write access to.  This sould be in the format 'arn:aws:s3:::bucket-name/path/*' | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | The ARN of the Lambda function |
| <a name="output_lambda_function_cloudwatch_log_group_name"></a> [lambda\_function\_cloudwatch\_log\_group\_name](#output\_lambda\_function\_cloudwatch\_log\_group\_name) | The name of the CloudWatch log group for the Lambda function |
