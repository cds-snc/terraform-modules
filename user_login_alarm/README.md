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
| [aws_cloudwatch_log_metric_filter.user_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_names"></a> [account\_names](#input\_account\_names) | (required) The account name to alarm on if it's found | `set(string)` | n/a | yes |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (required) The list of actions to execute when this alarm transitions to alarm state. Takes a set (array) of ARNs | `set(string)` | n/a | yes |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | (required) The log group to search for cloudtrail ConsoleLogin events in. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace for the metric | `string` | `"common-metrics"` | no |

## Outputs

No outputs.
