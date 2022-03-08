
 A wrapper on the SNS module that enfores a customer managed KMS key

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
| [aws_kms_key.sns_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_failure_feedback_role_arn"></a> [application\_failure\_feedback\_role\_arn](#input\_application\_failure\_feedback\_role\_arn) | (Optional) IAM role for failure feedback | `string` | `null` | no |
| <a name="input_application_success_feedback_role_arn"></a> [application\_success\_feedback\_role\_arn](#input\_application\_success\_feedback\_role\_arn) | (Optional) The IAM role permitted to receive success feedback for this topic | `string` | `null` | no |
| <a name="input_application_success_feedback_sample_rate"></a> [application\_success\_feedback\_sample\_rate](#input\_application\_success\_feedback\_sample\_rate) | (Optional) Percentage of success to sample | `number` | `null` | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | `null` | no |
| <a name="input_content_based_deduplication"></a> [content\_based\_deduplication](#input\_content\_based\_deduplication) | (Optional) Enables content-based deduplication for FIFO topics. For more information, see the related documentation | `bool` | `false` | no |
| <a name="input_delivery_policy"></a> [delivery\_policy](#input\_delivery\_policy) | (Optional) The SNS delivery policy. More on AWS documentation | `string` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | (Optional) The display name for the topic | `string` | `null` | no |
| <a name="input_fifo_topic"></a> [fifo\_topic](#input\_fifo\_topic) | (Optional) Boolean indicating whether or not to create a FIFO (first-in-first-out) topic (default is false). | `bool` | `false` | no |
| <a name="input_firehose_failure_feedback_role_arn"></a> [firehose\_failure\_feedback\_role\_arn](#input\_firehose\_failure\_feedback\_role\_arn) | (Optional) IAM role for failure feedback | `string` | `null` | no |
| <a name="input_firehose_success_feedback_role_arn"></a> [firehose\_success\_feedback\_role\_arn](#input\_firehose\_success\_feedback\_role\_arn) | (Optional) The IAM role permitted to receive success feedback for this topic | `string` | `null` | no |
| <a name="input_firehose_success_feedback_sample_rate"></a> [firehose\_success\_feedback\_sample\_rate](#input\_firehose\_success\_feedback\_sample\_rate) | (Optional) Percentage of success to sample | `number` | `null` | no |
| <a name="input_http_failure_feedback_role_arn"></a> [http\_failure\_feedback\_role\_arn](#input\_http\_failure\_feedback\_role\_arn) | (Optional) IAM role for failure feedback | `string` | `null` | no |
| <a name="input_http_success_feedback_role_arn"></a> [http\_success\_feedback\_role\_arn](#input\_http\_success\_feedback\_role\_arn) | (Optional) The IAM role permitted to receive success feedback for this topic | `string` | `null` | no |
| <a name="input_http_success_feedback_sample_rate"></a> [http\_success\_feedback\_sample\_rate](#input\_http\_success\_feedback\_sample\_rate) | (Optional) Percentage of success to sample | `number` | `null` | no |
| <a name="input_kms_event_sources"></a> [kms\_event\_sources](#input\_kms\_event\_sources) | (Optional) List of AWS services that can access the topic. | `list(string)` | `[]` | no |
| <a name="input_kms_iam_sources"></a> [kms\_iam\_sources](#input\_kms\_iam\_sources) | (Optional) List of AWS IAM role sources that can access the topic. | `list(string)` | `[]` | no |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | (Optional) The ARN of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK. For more information, see Key Terms | `string` | `null` | no |
| <a name="input_lambda_failure_feedback_role_arn"></a> [lambda\_failure\_feedback\_role\_arn](#input\_lambda\_failure\_feedback\_role\_arn) | (Optional) IAM role for failure feedback | `string` | `null` | no |
| <a name="input_lambda_success_feedback_role_arn"></a> [lambda\_success\_feedback\_role\_arn](#input\_lambda\_success\_feedback\_role\_arn) | (Optional) The IAM role permitted to receive success feedback for this topic | `string` | `null` | no |
| <a name="input_lambda_success_feedback_sample_rate"></a> [lambda\_success\_feedback\_sample\_rate](#input\_lambda\_success\_feedback\_sample\_rate) | (Optional) Percentage of success to sample | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the topic. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the .fifo suffix. If omitted, Terraform will assign a random, unique name. Conflicts with name\_prefix | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Creates a unique name beginning with the specified prefix. Conflicts with name | `string` | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) The fully-formed AWS policy as JSON. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. | `string` | `null` | no |
| <a name="input_sqs_failure_feedback_role_arn"></a> [sqs\_failure\_feedback\_role\_arn](#input\_sqs\_failure\_feedback\_role\_arn) | (Optional) IAM role for failure feedback | `string` | `null` | no |
| <a name="input_sqs_success_feedback_role_arn"></a> [sqs\_success\_feedback\_role\_arn](#input\_sqs\_success\_feedback\_role\_arn) | (Optional) The IAM role permitted to receive success feedback for this topic | `string` | `null` | no |
| <a name="input_sqs_success_feedback_sample_rate"></a> [sqs\_success\_feedback\_sample\_rate](#input\_sqs\_success\_feedback\_sample\_rate) | (Optional) Percentage of success to sample | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | KMS Key ARN used for SNS |
| <a name="output_sns_arn"></a> [sns\_arn](#output\_sns\_arn) | The ARN of the SNS topic. |
| <a name="output_sns_id"></a> [sns\_id](#output\_sns\_id) | The name of the SNS topic. |
