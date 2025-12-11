# Migration Guide — notify_slack → sns + HTTPS subscription

This module is deprecated. Follow the steps below to migrate to the recommended pattern using the `sns` module and an HTTPS SNS subscription to your Slack Incoming Webhook.

## Summary

- Keep the SNS topic managed by our `sns` module (handles KMS, tags, naming).
- Create an `aws_sns_topic_subscription` with `protocol = "https"` and `endpoint = <your_slack_webhook>`.
- Optionally move Terraform state to the new configuration to avoid resource recreation.

## Example (module usage)

```hcl
module "alerts_sns" {
  source            = "github.com/cds-snc/terraform-modules//sns?ref=vX.Y""
  name              = "my-alerts-topic"
  billing_tag_value = "TeamX"
  # pass other inputs as needed
}

variable "slack_webhook_url" {
  description = "Slack incoming webhook URL."
  type      = string
  sensitive = true
}

resource "aws_sns_topic_subscription" "slack" {
  topic_arn            = module.alerts_sns.sns_arn
  protocol             = "https"
  endpoint             = var.slack_webhook_url
  raw_message_delivery = true
}
