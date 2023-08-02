locals {
  common_tags = {
    (var.billing_tag_key)  = var.billing_tag_value
    Terraform              = "true"
    (var.critical_tag_key) = var.critical_tag_value ? "true" : "false"
  }
  # conditional logging block: 
  # if configure_critical_bucket_logs is true, then set the S3 Log Bucket required parameters:
  # 1. s3_log_bucket
  s3_log_bucket = var.configure_critical_bucket_logs ? {
    bucket_name = "${var.bucket_name}-server-logs"
    billing_tag_key   = var.billing_tag_key
    billing_tag_value = var.billing_tag_value
  } : {}
  # 2. sentinel_forwarder
  sentinel_forwarder = var.configure_critical_bucket_logs ? {
    function_name     = "${var.bucket_name}-logs-sentinel-forwarder"
    billing_tag_key   = var.billing_tag_key
    billing_tag_value = var.billing_tag_value
    log_type          = "AWSS3ServerAccessLogs"
    bucket_arn        = module.s3_log_bucket[0].s3_bucket_arn
    bucket_id         = module.s3_log_bucket[0].s3_bucket_id
    filter_prefix     = "logs/"
    kms_key_arn       = ""
  } : {}
}
