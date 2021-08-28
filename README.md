
# CDS Common Terraform Modules

- [CDS Common Terraform Modules](#cds-common-terraform-modules)
  - [Module List](#module-list)
  - [How to use modules in this repo](#how-to-use-modules-in-this-repo)

## Module List

- [User Login Alarm](user_login_alarm)
- [VPC](vpc)
- [RDS](rds)
- [S3](s3)
- [S3_log_bucket](S3_log_bucket)
- [Monolith](Monolith)

## How to use modules in this repo

[Official instructions for Terraform module usage](https://www.terraform.io/docs/language/modules/syntax.html)

To reference modules in this repo use the following `source` setting:

```hcl
  source = "github.com/cds-snc/terraform-modules?ref=<<version>>//<<Module Name>>
```

for instance the user_login_alarm module resource v0.0.1 would look like the following:

```hcl
module "console_login_alarms" {
  source                 = "github.com/cds-snc/terraform-modules?ref=v0.0.1//user_login_alarm
  account_names          = ["account1", "account2"]
  log_group_name         = "cloudtrailLogGroup"
  alarm_actions_failures = ["alarm_arn"]
  alarm_actions_success  = ["alarm_arn"]
}
```