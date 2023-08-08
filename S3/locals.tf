locals {
  common_tags = {
    (var.billing_tag_key)  = var.billing_tag_value
    Terraform              = "true"
    (var.critical_tag_key) = var.critical_tag_value ? "true" : "false"
  }
  s3_log_bucket = var.configure_critical_bucket_logs ? {
    bucket_name = "${var.bucket_name}-server-logs"
    billing_tag_key   = var.billing_tag_key
    billing_tag_value = var.billing_tag_value
  } : {}
}
