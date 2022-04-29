This is only needed for enrolling accounts to Guardduty that were created before Guarduty was enabled.
New accounts will be auto-enrolled by default if it was configured or if our Guardduty module was used.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.member_role"></a> [aws.member\_role](#provider\_aws.member\_role) | n/a |
| <a name="provider_aws.primary_role"></a> [aws.primary\_role](#provider\_aws.primary\_role) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_guardduty_invite_accepter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_invite_accepter) | resource |
| [aws_guardduty_member.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_member) | resource |
| [aws_caller_identity.member](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_guardduty_detector.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/guardduty_detector) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |

## Outputs

No outputs.
