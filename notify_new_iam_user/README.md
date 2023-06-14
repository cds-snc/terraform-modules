## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.new_iam_user_added_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.new_iam_user_added_event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.lambda_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.new_iam_user_response_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.new_iam_user_response_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.new_iam_user_added_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.notify_new_iam_user_added_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.notify_new_iam_user_added](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | (Optional) Name of the Lambda function. | `string` | `"new_iam_user_added"` | no |
| <a name="input_logging_level"></a> [logging\_level](#input\_logging\_level) | The logging level of the lambda function | `string` | `"ERROR"` | no |
| <a name="input_sns_topic"></a> [sns\_topic](#input\_sns\_topic) | (Required, default 'internal-sre-alert') The name of the sns topic to send alerts to | `string` | `"internal-sre-alert"` | no |

## Outputs

No outputs.
