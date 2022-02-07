Creates an OpenID Connect Role that can be used for authenticating workflows in Github Actions
This allows for a more secure way to connect to AWS as it doesn't rely on static credentials but uses temporary credentials created for each run.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.70.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.oidc_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [tls_certificate.thumprint](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_policy"></a> [assume\_policy](#input\_assume\_policy) | (Optional) Assume role JSON policy to attach to the oidc role | `string` | `"{}"` | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | (Optional)  The name of the org the workflow will be called from.<br>    In the format of http://github.com/`org_name` | `string` | `"cds-snc"` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | (Required) The list of roles to create for GH OIDC<br><br>  name: The name of the role to create<br><br>  repo\_name: The name of the repo to authenticate<br>  If you use `*` this will allow this role to be used in any repo in the org identified in `org_name`<br><br>  claim: The claim that the token is allowed to be authorized from. <br>  This allows you to further restrict where this role is allowed to be used.<br>  If you wanted to restrict to the main branch you could use a value like `ref:refs/heads/main`, if you don't want to restrict you can use `*`<br><br>  **Please Note:** You need to provide at least one role for this module to work. | <pre>set(object({<br>    name : string,<br>    repo_name : string,<br>    claim : string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_roles"></a> [roles](#output\_roles) | Returns all the roles created accessed by the name passed in to the module. |
