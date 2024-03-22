module "spend_notifier_example" {
  source                     = "github.com/cds-snc/terraform-modules//spend_notifier?ref=v9.2.5"
  daily_spend_notifier_hook  = "d5bfc2dc-07d9-4553-adbb-08a0b44a4bea"
  weekly_spend_notifier_hook = "d5bfc2dc-07d9-4553-adbb-08a0b44a4bea"
  billing_tag_value          = "My billing tag value"
  account_name               = "My account name"
}