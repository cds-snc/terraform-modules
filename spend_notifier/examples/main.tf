module "spend_notifier_example" {
  source                           = "../"
  daily_spend_notifier_hook        = var.daily_spend_notifier_hook
  weekly_spend_notifier_hook       = var.weekly_spend_notifier_hook
  billing_tag_value                = "My billing tag value"
  account_name                     = "123456789012"
  enable_daily_spend_notification  = true
  enable_weekly_spend_notification = true
  daily_schedule_expression        = "0 12 * * ? *"
  weekly_schedule_expression       = "0 12 ? * SUN *"
}