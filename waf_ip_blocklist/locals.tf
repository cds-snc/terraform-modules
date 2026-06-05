
locals {
  athena_query_results_bucket_arn = "arn:aws:s3:::${var.athena_query_results_bucket}"
  athena_query_source_bucket_arn  = "arn:aws:s3:::${var.athena_query_source_bucket}"
  blocklist_name                  = "ipv4_blocklist_${var.service_name}"

  common_tags = merge(
    {
      (var.billing_tag_key) = var.billing_tag_value
      Terraform             = "true"
    },
    var.ssc_cbrid_tag_value != "" ? { (var.ssc_cbrid_tag_key) = var.ssc_cbrid_tag_value } : {}
  )
}
