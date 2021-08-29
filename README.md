
# CDS Common Terraform Modules

- [CDS Common Terraform Modules](#cds-common-terraform-modules)
  - [Module List](#module-list)
  - [How to use modules in this repo](#how-to-use-modules-in-this-repo)
  - [Documentation Generation](#documentation-generation)

## Module List

- [User Login Alarm](user_login_alarm)
- [VPC](vpc)
- [RDS](rds)

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

## Documentation Generation

Documentation is automatically generated using the framework (terraform-docs)[https://terraform-docs.io/].

At a bare minimum you need to add a header to the main.tf file https://terraform-docs.io/user-guide/how-to/#module-header. You also need to document your variables. Optionally you can document your outputs if they aren't descriptive enough.

A github action will detect changes and update documentation in the PR.
