# Create an alarm for two accounts with no alarm actions
module "no_actions" {
  source                = "../../"
  account_names         = ["ops1", "ops2"]
  namespace             = "terratest"
  log_group_name        = "CloudTrail/Landing-Zone-Logs"
  alarm_actions_success = []
  alarm_actions_failure = []
  num_attempts          = 3
}
