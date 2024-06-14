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
| [aws_cloudwatch_event_rule.daily_budget_spend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.weekly_budget_spend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.daily_budget_spend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.weekly_budget_spend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.spend_notifier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.spend_notifier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_insights](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.spend_notifier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.spend_notifier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_daily_budget](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.allow_weekly_budget](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.spend_notifier](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy.lambda_insights](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.spend_notifier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.spend_notifier_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | (Required) The name of the account | `string` | `null` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | `null` | no |
| <a name="input_daily_schedule_expression"></a> [daily\_schedule\_expression](#input\_daily\_schedule\_expression) | (Optional) The schedule expression for the daily spend notification | `string` | `"0 12 * * ? *"` | no |
| <a name="input_daily_spend_notifier_hook"></a> [daily\_spend\_notifier\_hook](#input\_daily\_spend\_notifier\_hook) | (Required) The identifier of the webhook to be used by the spend notifier lambda daily | `string` | n/a | yes |
| <a name="input_enable_daily_spend_notification"></a> [enable\_daily\_spend\_notification](#input\_enable\_daily\_spend\_notification) | (Optional) Enable daily spend notification | `bool` | `true` | no |
| <a name="input_enable_weekly_spend_notification"></a> [enable\_weekly\_spend\_notification](#input\_enable\_weekly\_spend\_notification) | (Optional) Enable weekly spend notification | `bool` | `true` | no |
| <a name="input_weekly_schedule_expression"></a> [weekly\_schedule\_expression](#input\_weekly\_schedule\_expression) | (Optional) The schedule expression for the weekly spend notification | `string` | `"0 12 ? * SUN *"` | no |
| <a name="input_weekly_spend_notifier_hook"></a> [weekly\_spend\_notifier\_hook](#input\_weekly\_spend\_notifier\_hook) | (Required) The identifier of the webhook to be used by the spend notifier lambda weekly | `string` | n/a | yes |

## Outputs

No outputs.
