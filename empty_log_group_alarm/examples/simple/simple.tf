
module "simple" {
  source = "../../"

  alarm_sns_topic_arn = "arn:aws:sns:ca-central-1:000000000000:alert"
  log_group_names     = ["/aws/lambda/foo"]

  use_anomaly_detection = true

  billing_tag_value = "Terratest"
}

