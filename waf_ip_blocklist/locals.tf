
locals {
  athena_query_results_bucket_arn = "arn:aws:s3:::${var.athena_query_results_bucket}"
  blocklist_name                  = "ipv4_blocklist_${var.service_name}"

  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
}
