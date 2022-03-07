# aws\_goc\_password\_policy

Implements the recommend [Government of Canada Password Guidance](https://www.canada.ca/en/government/system/digital-government/online-security-privacy/password-guidance.html) for AWS Accounts.
This is required in order to meet the ["Management of Administrative Privilges"](https://github.com/canada-ca/cloud-guardrails/blob/master/EN/02_Management-Admin-Privileges.md) Guardrail that is part of the [GC Cloud Guardrails](https://github.com/canada-ca/cloud-guardrails) that need to be implemented in the first 30 days of acquiring an AWS Organization

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
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |

## Inputs

No inputs.

## Outputs

No outputs.
