# Sentinel forwarder

This module sets up a lambda that will forward AWS logs to Azure Sentinel.
It is a light wrapper on the code found here (https://github.com/cds-snc/aws-sentinel-connector-layer) and
just stitches together the code with the triggers.

Triggers can be EventHub rules, S3 ObjectCreated events, or CloudWatch Log Subscriptions. The following log types are supported:
- CloudTrail (.json.gz)
- Load balancer (.log.gz)
- VPC flow logs (.log.gz)
- WAF ACL (.gz)
- GuardDuty
- SecurityHub (via EventHub)
- Generic application json logs

You will need to add your Log Analytics Workspace Customer ID and Shared Key. AWS logs are automatically assigned a LogType.
Custom application logs are given the log type defined through the `var.log_type`. They also need to be nested inside a json
object with the key, `application_log`. ex: `{'application_log': {'foo': 'bar'}}` for the layer code to forward it to Azure Sentinel.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.46.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.46.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_target.sentinel_forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.sentinel_forwarder_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.sentinel_forwarder_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.sentinel_forwarder_lambda_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.sentinel_forwarder_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.sentinel_forwarder_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sentinel_forwarder_lambda_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.sentinel_forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.sentinel_forwarder_cloudwatch_log_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.sentinel_forwarder_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.sentinel_forwarder_s3_triggers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket_notification.sentinel_forwarder_trigger_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_ssm_parameter.sentinel_forwarder_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [archive_file.sentinel_forwarder](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda_assume_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sentinel_forwarder_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sentinel_forwarder_lambda_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_cloudwatch_log_arns"></a> [cloudwatch\_log\_arns](#input\_cloudwatch\_log\_arns) | (Optional) A list of CloudWatch log ARNs to forward to Sentinel | `list(string)` | `[]` | no |
| <a name="input_customer_id"></a> [customer\_id](#input\_customer\_id) | (Required) Azure log workspace customer ID | `string` | n/a | yes |
| <a name="input_event_rule_names"></a> [event\_rule\_names](#input\_event\_rule\_names) | (Optional) List of names for event rules to trigger the lambda | `list(string)` | `[]` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | (Required) Name of the Lambda function. | `string` | n/a | yes |
| <a name="input_layer_arn"></a> [layer\_arn](#input\_layer\_arn) | (Optional) ARN of the lambda layer to use | `string` | `"arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:20"` | no |
| <a name="input_log_type"></a> [log\_type](#input\_log\_type) | (Optional) The namespace for logs. This only applies if you are sending application logs | `string` | `"ApplicationLog"` | no |
| <a name="input_s3_sources"></a> [s3\_sources](#input\_s3\_sources) | (Optional) List of s3 buckets to trigger the lambda | <pre>list(object({<br/>    bucket_arn    = string<br/>    bucket_id     = string<br/>    filter_prefix = string<br/>    kms_key_arn   = string<br/>  }))</pre> | `[]` | no |
| <a name="input_shared_key"></a> [shared\_key](#input\_shared\_key) | (Required) Azure log workspace shared secret | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | The ARN of the Lambda function. |
| <a name="output_lambda_name"></a> [lambda\_name](#output\_lambda\_name) | The name of the Lambda function. |
