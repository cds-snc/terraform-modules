This module creates an AWS Backup vault that uses the AWS-managed AWS Backup KMS key.

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.15.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.15.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_backup_vault.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault_lock_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_lock_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag. | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag. | `string` | n/a | yes |
| <a name="input_changeable_for_days"></a> [changeable\_for\_days](#input\_changeable\_for\_days) | (Optional) The number of days before a compliance-mode vault lock becomes immutable. Omit to use governance mode. | `number` | `null` | no |
| <a name="input_max_retention_days"></a> [max\_retention\_days](#input\_max\_retention\_days) | (Optional) The maximum retention period in days accepted by the vault lock, up to three years. | `number` | `null` | no |
| <a name="input_min_retention_days"></a> [min\_retention\_days](#input\_min\_retention\_days) | (Optional) The minimum retention period in days accepted by the vault lock, up to three years. | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the AWS Backup vault. | `string` | n/a | yes |
| <a name="input_ssc_cbrid_tag_key"></a> [ssc\_cbrid\_tag\_key](#input\_ssc\_cbrid\_tag\_key) | (Optional, default 'ssc\_cbrid') The tag key for the SSC CBRID. | `string` | `"ssc_cbrid"` | no |
| <a name="input_ssc_cbrid_tag_value"></a> [ssc\_cbrid\_tag\_value](#input\_ssc\_cbrid\_tag\_value) | (Optional) The value of the SSC CBRID tag. If empty, the tag will not be applied. | `string` | `"22DH"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_backup_vault_arn"></a> [backup\_vault\_arn](#output\_backup\_vault\_arn) | The ARN of the AWS Backup vault. |
| <a name="output_backup_vault_id"></a> [backup\_vault\_id](#output\_backup\_vault\_id) | The ID of the AWS Backup vault. |
| <a name="output_backup_vault_name"></a> [backup\_vault\_name](#output\_backup\_vault\_name) | The name of the AWS Backup vault. |
