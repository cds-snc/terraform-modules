# Empty lpg group alarm

This module creates a CloudWatch alarm that triggers when a log group is not receiving the expected amount of
data based on the `IncomingLogEvents` metric. The input is a list of log group names ex. ["/aws/lambda/
my-lambda", "/aws/lambda/my-other-lambda"] as well as the arn of a SNS topic to send the alarm to. The module
also incudes the flag `use_anomaly_detection` which will use anomaly detection feature to determine the expected
amount of data, otherwise it will alert on log groups that receive 0 `IncomingLogEvents` over the time period.

Note: AWS anomaly detection works best in very specific, unclear, circumstances.

Example usage:
```
module "empty_log_group_alarm" {
  source              = "github.com/terraform-aws-modules/terraform-aws-cloudwatch-log-empty-log-group-alarm"
  alarm_sns_topic_arn = "arn:aws:sns:ca-central-1:000000000000:alert"
  log_group_names     = ["/aws/lambda/foo"]
  billing_tag_value   = "TagValue"
}
```

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
| [aws_cloudwatch_metric_alarm.empty_log_group_metric_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.empty_log_group_metric_alarm_using_anomaly_detection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_sns_topic_arn"></a> [alarm\_sns\_topic\_arn](#input\_alarm\_sns\_topic\_arn) | (Required) The ARN to send the alarm to | `string` | n/a | yes |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_log_group_names"></a> [log\_group\_names](#input\_log\_group\_names) | (Required) The list of log group names to monitor | `list(string)` | `[]` | no |
| <a name="input_time_period_minutes"></a> [time\_period\_minutes](#input\_time\_period\_minutes) | (Optional, default 5) The time period in minutes to check for incoming logs | `number` | `5` | no |
| <a name="input_use_anomaly_detection"></a> [use\_anomaly\_detection](#input\_use\_anomaly\_detection) | n/a | `bool` | `false` | no |

## Outputs

No outputs.
