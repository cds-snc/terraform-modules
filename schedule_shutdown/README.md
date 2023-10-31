# Schedule shutdown
Lambda function to schedule resource shutdown and startup to save costs.  The function is triggered by CloudWatch Events
controlled by schedule expressions.   

Currently the function supports scaling the following resources:
- CloudWatch alarms: enables/disables the alarm actions.
- ECS services: scales the service between 0 and 1 tasks.
- RDS clusters: stops/starts the cluster.
- Route53 healthchecks: enables/disables the healthcheck.

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
| [aws_cloudwatch_event_rule.schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.schedule](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch_alarm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_service_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.rds_cluster_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.route53_healthcheck_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_cloudwatch_alarm_arns"></a> [cloudwatch\_alarm\_arns](#input\_cloudwatch\_alarm\_arns) | (Optional) CloudWatch alarm ARNs to enable/disable. | `list(string)` | `[]` | no |
| <a name="input_ecs_service_arns"></a> [ecs\_service\_arns](#input\_ecs\_service\_arns) | (Optional) ECS service ARNs to scale up/down. | `list(string)` | `[]` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | (Optional, defaults to 3.11) The Python runtime to use for the lambda function. | `string` | `"python3.11"` | no |
| <a name="input_rds_cluster_arns"></a> [rds\_cluster\_arns](#input\_rds\_cluster\_arns) | (Optional) RDS cluster ARNs to shutdown and startup. | `list(string)` | `[]` | no |
| <a name="input_route53_healthcheck_arns"></a> [route53\_healthcheck\_arns](#input\_route53\_healthcheck\_arns) | (Optional) Route53 healthcheck ARNs to enable/disable. | `list(string)` | `[]` | no |
| <a name="input_schedule_shutdown"></a> [schedule\_shutdown](#input\_schedule\_shutdown) | (Optional, every day at 10pm UTC) The schedule expression for when resources should be stopped. | `string` | `"cron(0 22 * * ? *)"` | no |
| <a name="input_schedule_startup"></a> [schedule\_startup](#input\_schedule\_startup) | (Optional, Monday-Friday at 10am UTC) The schedule expression for when resources should be started. | `string` | `"cron(0 10 ? * MON-FRI *)"` | no |

## Outputs

No outputs.
