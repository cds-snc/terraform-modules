# CDS Common Terraform Modules


## How to use this module

Instructions for Terraform Module usage can be found here: 
https://www.terraform.io/docs/language/modules/syntax.html

To reference modules in this repo use the following `source` setting:

```hcl
  source = "github.com/cds-snc/terraform-modules//<<Module Name>>
```

for instance the user_login_alarm module resource would look like the following:

```hcl
module "console_login_alarms" {
  source         = "github.com/cds-snc/terraform-modules//user_login_alarm
  account_names  = ["account1", "account2"]
  log_group_name = "cloudtrailLogGroup"
  alarm_actions  = ["alarm_arn"]
}
```
## Module List
- [User Login Alarm](user_login_alarm)