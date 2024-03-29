module "spend_notifier_example" {
  source                     = "github.com/cds-snc/terraform-modules//spend_notifier?ref=v9.2.5"
  daily_spend_notifier_hook  = var.daily_spend_notifier_hook
  weekly_spend_notifier_hook = var.weekly_spend_notifier_hook
  billing_tag_value          = "My billing tag value"
  account_name               = "My account name"
}