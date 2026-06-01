locals {
  common_tags = merge(
    {
      (var.billing_tag_key)  = var.billing_tag_value
      Terraform              = "true"
      (var.critical_tag_key) = var.critical_tag_value ? "true" : "false"
    },
    var.ssc_cbrid_tag_value != "" ? { (var.ssc_cbrid_tag_key) = var.ssc_cbrid_tag_value } : {}
  )
}
