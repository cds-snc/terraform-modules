locals {
  common_tags = {
    (var.billing_tag_key)  = var.billing_tag_value
    Terraform              = "true"
    (var.critical_tag_key) = var.critical_tag_value ? "true" : "false"
  }
  s3_log_bucket = var.configure_critical_bucket_logs ? {
    bucket_name                  = "${var.bucket_name}-server-logs"
    billing_tag_key              = var.billing_tag_key
    billing_tag_value            = var.billing_tag_value
    customer_id                  = var.customer_id
    shared_key                   = var.shared_key
    configure_sentinel_forwarder = true
  } : {}
  logging_configuration = concat(
    [
      for key, value in var.logging : {
        target_bucket = key
        target_prefix = value
      }
    ],
    var.configure_critical_bucket_logs ? [
      {
        target_bucket = local.s3_log_bucket.bucket_name
        target_prefix = "logs/"
      }
    ] : []
  )

  logging_configuration_objects = [
    for config in local.logging_configuration : {
      target_bucket = config.target_bucket
      target_prefix = config.target_prefix
    }
  ]
}
