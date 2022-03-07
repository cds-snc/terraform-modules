/* 
* # aws_goc_password_policy
* 
* Implements the recommend [Government of Canada Password Guidance](https://www.canada.ca/en/government/system/digital-government/online-security-privacy/password-guidance.html) for AWS Accounts.
* This is required in order to meet the ["Management of Administrative Privilges"](https://github.com/canada-ca/cloud-guardrails/blob/master/EN/02_Management-Admin-Privileges.md) Guardrail that is part of the [GC Cloud Guardrails](https://github.com/canada-ca/cloud-guardrails) that need to be implemented in the first 30 days of acquiring an AWS Organization
* 
*/

resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = 12
  require_symbols                = true
  require_numbers                = true
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  allow_users_to_change_password = true
  hard_expiry                    = false
  password_reuse_prevention      = 24
}
