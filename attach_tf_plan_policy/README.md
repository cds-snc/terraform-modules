This creates a policy that allows access to dynamodb, s3 state bucket
and gives the ability to read secrets.

**Please Note:** This may too permissive for what you want to do so you might want to further lock it down.

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
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy.readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Required) The ID of the AWS account to add permissions for | `string` | n/a | yes |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | (Required) The name of the s3 bucket the state is being kept in | `string` | n/a | yes |
| <a name="input_lock_table_name"></a> [lock\_table\_name](#input\_lock\_table\_name) | (Optional) The name of the table the locks for the state file are in | `string` | `"terraform-state-lock-dynamo"` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | (Optional) The name of the policy that will be attached to the role.<br/>    **Please Note:** This is only needed to be set if the default value conflicts with an existing policy name in this account. | `string` | `"TFPlan"` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region the resources are in | `string` | `"ca-central-1"` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | (Required) The name of the role to attach the policy to | `string` | n/a | yes |

## Outputs

No outputs.
