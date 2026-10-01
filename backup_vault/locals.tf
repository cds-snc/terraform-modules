locals {
  common_tags = merge(
    {
      (var.billing_tag_key) = var.billing_tag_value
      Terraform             = "true"
    },
    var.ssc_cbrid_tag_value != "" ? { (var.ssc_cbrid_tag_key) = var.ssc_cbrid_tag_value } : {}
  )

  vault_lock_enabled = anytrue([
    var.min_retention_days != null,
    var.max_retention_days != null,
    var.changeable_for_days != null,
  ])
}