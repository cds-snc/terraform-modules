locals {
  common_tags = {
    (var.billing_tag_key)  = var.billing_tag_value
    Terraform              = "true"
    (var.critical_tag_key) = var.critical_tag_value ? "true" : "false"
  }
  sentinel_forwarder = var.configure_sentinel_forwarder ? {
    function_name     = "${var.bucket_name}-logs-sentinel-forwarder"
    billing_tag_key   = var.billing_tag_key
    billing_tag_value = var.billing_tag_value
    log_type          = "AWSS3ServerAccessLogs"
    bucket_arn        = aws_s3_bucket.this.arn
    bucket_id         = aws_s3_bucket.this.id
    filter_prefix     = "logs/"
    kms_key_arn       = ""
  } : {}
}
