
This module creates a lambda function and a role. It also has toggles for the various ways lambdas are invoked at CDS.

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
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_query_definition.lambda_statistics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_query_definition) | resource |
| [aws_iam_policy.non_vpc_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.vpc_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.AWSLambdaVPCAccessExecutionRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_insights](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.non_vpc_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.vpc_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_alias) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.s3_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket_notification.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_iam_policy.lambda_insights](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.non_vpc_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service_principal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alias_name"></a> [alias\_name](#input\_alias\_name) | (Optional, default '') Lambda function's alias name | `string` | `""` | no |
| <a name="input_allow_api_gateway_invoke"></a> [allow\_api\_gateway\_invoke](#input\_allow\_api\_gateway\_invoke) | (Optional) Allow API Gateway to invoke the lambda | `bool` | `false` | no |
| <a name="input_allow_s3_execution"></a> [allow\_s3\_execution](#input\_allow\_s3\_execution) | (Optional) Allow S3 to execute the lambda | `bool` | `false` | no |
| <a name="input_api_gateway_source_arn"></a> [api\_gateway\_source\_arn](#input\_api\_gateway\_source\_arn) | (Optional) The api gateway rest point that can call the lambda | `string` | `""` | no |
| <a name="input_architectures"></a> [architectures](#input\_architectures) | (Optional) The architectures that the lambda can run on | `list(any)` | <pre>[<br/>  "x86_64"<br/>]</pre> | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | (Optional) S3 bucket that is triggering the lambda | <pre>object({<br/>    id  = string<br/>    arn = string<br/>  })</pre> | <pre>{<br/>  "arn": "",<br/>  "id": ""<br/>}</pre> | no |
| <a name="input_dead_letter_queue_arn"></a> [dead\_letter\_queue\_arn](#input\_dead\_letter\_queue\_arn) | (Optional) The arn of the dead letter queue | `string` | `""` | no |
| <a name="input_ecr_arn"></a> [ecr\_arn](#input\_ecr\_arn) | (Optional) The arn of the ecr repository the image resides in the lambda will be given access to pull images and layers from this registry | `string` | n/a | yes |
| <a name="input_enable_lambda_insights"></a> [enable\_lambda\_insights](#input\_enable\_lambda\_insights) | (Optional) Enable Lambda Insights | `bool` | `true` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | (Optional) Environment variables to pass to the lambda | `map(string)` | `{}` | no |
| <a name="input_ephemeral_storage"></a> [ephemeral\_storage](#input\_ephemeral\_storage) | (Optional) Set the Lambda function's ephemeral storage to a value between 512MB and 10240MB. | `number` | `512` | no |
| <a name="input_file_system_config"></a> [file\_system\_config](#input\_file\_system\_config) | (Optional) Configuration to connect EFS to a Lambda function. | `map(string)` | `{}` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | (Required) Docker image URI | `string` | n/a | yes |
| <a name="input_log_group_retention_period"></a> [log\_group\_retention\_period](#input\_log\_group\_retention\_period) | (Optional) Override the retention period for the lambda log group | `number` | `14` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | (Optional) Memory in MB | `number` | `128` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the lambda | `string` | n/a | yes |
| <a name="input_policies"></a> [policies](#input\_policies) | (Optional) List of policies to attach to the Lambda function | `list(string)` | `[]` | no |
| <a name="input_publish"></a> [publish](#input\_publish) | (Optional, default 'false') Whether to publish creation/change as new Lambda Function Version. | `bool` | `false` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | (Optional) Amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1. See [Managing Concurrency](https://docs.aws.amazon.com/lambda/latest/dg/concurrent-executions.html) | `number` | `-1` | no |
| <a name="input_sns_topic_arns"></a> [sns\_topic\_arns](#input\_sns\_topic\_arns) | (Optional) SNS triggers to attach to the Lambda function | `list(string)` | `[]` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | (Optional) Timeout in seconds | `number` | `3` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | (Optional) VPC to attach to the Lambda function <br/> **Please Note if this is set it will also attach the AWSLambdaVPCAccessExecutionRole to the lmabda this will enable creation of VPC ENI's as well as reading and writing to logfiles | <pre>object({<br/>    subnet_ids         = list(string)<br/>    security_group_ids = list(string)<br/>  })</pre> | <pre>{<br/>  "security_group_ids": [],<br/>  "subnet_ids": []<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the Lambda function. |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the Lambda function. |
| <a name="output_function_role_arn"></a> [function\_role\_arn](#output\_function\_role\_arn) | ARN of the Lambda function execution role. |
| <a name="output_function_version"></a> [function\_version](#output\_function\_version) | Version of the Lambda function. |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | ARN used to invoke the Lambda function. |
