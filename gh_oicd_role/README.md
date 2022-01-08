Creates an OpenID Connect Role that can be used for authenticating workflows in Github Actions
This allows for a more secure way to connect to AWS as it doesn't rely on static credentials but uses temporary credentials created for each run.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.asume_role_saml](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [tls_certificate.thumprint](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_claim"></a> [claim](#input\_claim) | (Optional) The claim that the token is allowed to be authorized from.<br>    This allows you to restrict to specific branches in your repo. <br><br>    Defaults to `*` which allows you to use this token anywhere in your repo. <br><br>    If you wanted to restrict to the main branch you could use a value like `ref:refs/heads/main` | `string` | `"*"` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | (Optional)  The name of the org the workflow will be called from.<br>    In the format of http://github.com/`org_name` | `string` | `"cds-snc"` | no |
| <a name="input_repo"></a> [repo](#input\_repo) | (Required) The name of the repo that will be the workflow will be called from.<br>    In the format of http://github.com/cds-snc/`repo`<br><br>    If you use `*` this will allow this role to be used in any repo in the org identified in `org_name` | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | (Required) The name of the role to create | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | This is the arn of the IAM Role that will be authenticated using OICD.<br>This is needed for assigning roles to that authenticated IAM Role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | (Optional) The name of the role that will be impersonated using OICD |
