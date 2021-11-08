
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
| [aws_iam_policy.policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.AWSLambdaVPCAccessExecutionRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_insights](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.s3_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket_notification.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_iam_policy.lambda_insights](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.service_principal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_api_gateway_invoke"></a> [allow\_api\_gateway\_invoke](#input\_allow\_api\_gateway\_invoke) | (Optional) Allow API Gateway to invoke the lambda | `bool` | `false` | no |
| <a name="input_allow_s3_execution"></a> [allow\_s3\_execution](#input\_allow\_s3\_execution) | (Optional) Allow S3 to execute the lambda | `bool` | `false` | no |
| <a name="input_api_gateway_source_arn"></a> [api\_gateway\_source\_arn](#input\_api\_gateway\_source\_arn) | (Optional) The api gateway rest point that can call the lambda | `string` | `""` | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | (Optional) S3 bucket that is triggering the lambda | <pre>object({<br>    id  = string<br>    arn = string<br>  })</pre> | <pre>{<br>  "arn": "",<br>  "id": ""<br>}</pre> | no |
| <a name="input_enable_lambda_insights"></a> [enable\_lambda\_insights](#input\_enable\_lambda\_insights) | (Optional) Enable Lambda Insights | `bool` | `true` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | (Optional) Environment variables to pass to the lambda | `map(string)` | `{}` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | (Required) Docker image URI | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | (Optional) Memory in MB | `number` | `128` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the lambda | `string` | n/a | yes |
| <a name="input_policies"></a> [policies](#input\_policies) | (Optional) List of policies to attach to the Lambda function | `list(string)` | `[]` | no |
| <a name="input_sns_topic_arns"></a> [sns\_topic\_arns](#input\_sns\_topic\_arns) | (Optional) SNS triggers to attach to the Lambda function | `list(string)` | `[]` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | (Optional) Timeout in seconds | `number` | `3` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | (Optional) VPC to attach to the Lambda function | <pre>object({<br>    subnet_ids         = list(string)<br>    security_group_ids = list(string)<br>  })</pre> | <pre>{<br>  "security_group_ids": [],<br>  "subnet_ids": []<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | n/a |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | n/a |
