# CodeBuild GitHub runner

Creates an AWS CodeBuild project that allows you to self-host serverless GitHub action runners.

OAuth authentication with GitHub and the webhook to trigger this runner must be configured manually in the AWS console as the AWS CodeBuild API does not support OAuth configuration.

Inspiration for this module was taken from [cloudandthings/terraform-aws-github-runners](https://github.com/cloudandthings/terraform-aws-github-runners)

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
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codebuild_project.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_build_timeout"></a> [build\_timeout](#input\_build\_timeout) | (Optional, default '30') Build timeout for the CodeBuild project. | `number` | `30` | no |
| <a name="input_environment_compute_type"></a> [environment\_compute\_type](#input\_environment\_compute\_type) | (Optional, default 'BUILD\_GENERAL1\_SMALL') Compute type for the CodeBuild environment. | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_environment_image"></a> [environment\_image](#input\_environment\_image) | (Optional, default 'aws/codebuild/amazonlinux2-x86\_64-standard:5.0') Image for the CodeBuild environment. | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:5.0"` | no |
| <a name="input_environment_image_pull_credentials_type"></a> [environment\_image\_pull\_credentials\_type](#input\_environment\_image\_pull\_credentials\_type) | (Optional, default 'CODEBUILD') Image pull credentials type for the CodeBuild environment. | `string` | `"CODEBUILD"` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | (Optional, default 'LINUX\_CONTAINER') Environment type for the CodeBuild project. | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | (Optional, default []) Environment variables for the CodeBuild project. | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_github_repository_url"></a> [github\_repository\_url](#input\_github\_repository\_url) | (Required) GitHub repository URL for the CodeBuild source. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | (Required) Name of the CodeBuild project. | `string` | n/a | yes |
| <a name="input_queued_timeout"></a> [queued\_timeout](#input\_queued\_timeout) | (Optional, default '5') Queued timeout for the CodeBuild project. | `number` | `5` | no |

## Outputs

No outputs.
