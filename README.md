
# CDS Common Terraform Modules

- [CDS Common Terraform Modules](#cds-common-terraform-modules)
  - [Module List](#module-list)
  - [What is this repo?](#what-is-this-repo)
  - [Why would you use this repo](#why-would-you-use-this-repo)
  - [How to use modules in this repo](#how-to-use-modules-in-this-repo)
  - [Documentation Generation](#documentation-generation)
  - [Scaffolding](#scaffolding)

## Module List

- [Athena Access Logs](athena_access_logs)
- [Attach TF plan policy](attach_tf_plan_policy)
- [Auto Revoke SG Rules](auto_revoke_sg_rules)
- [AWS Government of Canada password policy](aws_goc_password_policy)
- [CDS Conformance Pack](cds_conformance_pack)
- [Client VPN](client_vpn)
- [Empty log group alarm](empty_log_group_alarm)
- [ECS](ecs)
- [Exposed IAM Credentials disabler](exposed_iam_credentials_disabler)
- [GuardDuty](guardduty)
- [GuardDuty member](guardduty_member)
- [Github Open ID Connect](gh_oidc_role)
- [Lambda](lambda)
- [Lambda response](lambda_response)
- [Lambda schedule](lambda_schedule)
- [Notify New IAM user](notify_new_iam_user)
- [Notify Slack](notify_slack)
- [RDS](rds)
- [RDS activity stream](rds_activity_stream)
- [Resolver DNS](resolver_dns)
- [S3](S3)
- [S3 log bucket](S3_log_bucket)
- [S3 scan object](S3_scan_object)
- [Schedule shutdown](schedule_shutdown)
- [Sentinel Alert Rule](sentinel_alert_rule)
- [Sentinel forwarder](sentinel_forwarder)
- [Simple static website](simple_static_website)
- [SNS](sns)
- [Spend Notifier](spend_notifier)
- [User login alarm](user_login_alarm)
- [VPC](vpc)
- [WAF IP blocklist](waf_ip_blocklist)

## What is this repo?

This repo is a collection of modules made by folks at CDS. It is a collection of policies, best practices, and repeated patterns. You do not have to use these modules but it is recommended by the **SREs** at CDS that you do. If you have a reason for not using one of these modules we'd love to here about it so we can modify them to fit your need.


## Why would you use this repo

- This code is currently in use in several products
- This code is tested by Terratest
- This code embeds security features
- This code is fully documented
- This code follows what CDS SREs consider best practices
- The more people that use it the better it is.
- The code is opinionated and so removes the need for discussion on certain topics.
- There are only so many ways to put together infrastructure so it's probably going to end up looking pretty close to this anyways. You might as well not reinvent the wheel here.

## How to use modules in this repo

[Official instructions for Terraform module usage](https://www.terraform.io/docs/language/modules/syntax.html)

To reference modules in this repo use the following `source` setting:

```hcl
  source = "github.com/cds-snc/terraform-modules//>>Module Name>>?ref=<<version>>
```

for instance the user_login_alarm module resource v0.0.1 would look like the following:

```hcl
module "console_login_alarms" {
  source                 = "github.com/cds-snc/terraform-modules//user_login_alarm?ref=v0.0.1
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

## Scaffolding

When creating a module it's recommended you use a scaffold to create the minimum required files for a module. 

You run the scaffold like so:

```bash
make scaffold
```

The script will prompt you for a scaffold name.

**Please Note**: `output.tf` is optional if you have no outputs, `locals.tf` is also optional if you don't have any taggable resources.
