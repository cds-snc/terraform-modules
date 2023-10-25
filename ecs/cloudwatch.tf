################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${var.cluster_name}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  tags              = local.common_tags
}

# Forward logs to Sentinel
module "sentinel_forwarder" {
  count             = var.sentinel_forwarder ? 1 : 0
  source            = "github.com/cds-snc/terraform-modules//sentinel_forwarder?ref=main"
  function_name     = substr(var.cluster_name, 0, 64)
  billing_tag_value = var.billing_tag_value

  layer_arn   = var.sentinel_forwarder_layer_arn
  customer_id = var.sentinel_customer_id
  shared_key  = var.sentinel_shared_key

  cloudwatch_log_arns = [
    aws_cloudwatch_log_group.this.arn,
  ]
}

resource "aws_cloudwatch_log_subscription_filter" "this_sentinel_forwarder" {
  count           = var.sentinel_forwarder ? 1 : 0
  name            = "All cluster logs"
  log_group_name  = aws_cloudwatch_log_group.this.name
  filter_pattern  = var.sentinel_fowarder_filter_pattern
  destination_arn = module.sentinel_forwarder[0].lambda_arn
  distribution    = "Random"
}
