Adapted from https://github.com/aws-samples/amazon-guardduty-for-aws-organizations-with-terraform

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.guardduty_region"></a> [aws.guardduty\_region](#provider\_aws.guardduty\_region) | n/a |
| <a name="provider_aws.guarduty_region"></a> [aws.guarduty\_region](#provider\_aws.guarduty\_region) | n/a |
| <a name="provider_aws.management_region"></a> [aws.management\_region](#provider\_aws.management\_region) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_guardduty_detector.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | resource |
| [aws_guardduty_organization_admin_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource |
| [aws_guardduty_organization_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) | resource |
| [aws_guardduty_publishing_destination.pub_dest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_publishing_destination) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_delegated_admin_account_id"></a> [delegated\_admin\_account\_id](#input\_delegated\_admin\_account\_id) | The account id of the delegated admin. | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | (Required) The KMS key to encrypt findings in the S3 bucket | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | The AWS organization to enable GuardDuty in. | `string` | n/a | yes |
| <a name="input_publishing_bucket_arn"></a> [publishing\_bucket\_arn](#input\_publishing\_bucket\_arn) | (Required) The ARN of the S3 bucket to publish findings to | `string` | n/a | yes |
| <a name="input_publishing_frequency"></a> [publishing\_frequency](#input\_publishing\_frequency) | Specifies the frequency of notifications sent for subsequent finding occurrences. | `string` | `"FIFTEEN_MINUTES"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. If configured with a provider default\_tags configuration block present,<br/>  tags with matching keys will overwrite those defined at the provider-level." | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_guardduty_detector"></a> [guardduty\_detector](#output\_guardduty\_detector) | The GuardDuty detector. |
