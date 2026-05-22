
locals {
  is_cloudwatch_alarm_arns    = length(var.cloudwatch_alarm_arns) > 0
  is_ecs_arns                 = length(var.ecs_service_arns) > 0
  is_rds_arns                 = length(var.rds_cluster_arns) > 0
  is_route53_healthcheck_arns = length(var.route53_healthcheck_arns) > 0
  lambda_name                 = "schedule-shutdown"

  schedule = {
    "shutdown" : var.schedule_shutdown,
    "startup" : var.schedule_startup,
  }

  common_tags = merge(
    {
      (var.billing_tag_key) = var.billing_tag_value
      Terraform             = "true"
    },
    var.ssc_cbrid_tag_value != "" ? { (var.ssc_cbrid_tag_key) = var.ssc_cbrid_tag_value } : {}
  )
}

