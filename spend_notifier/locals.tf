locals {
  common_tags = merge(
    {
      CostCentre = var.billing_tag_value
      Terraform  = "true"
    },
    var.ssc_cbrid_tag_value != "" ? { (var.ssc_cbrid_tag_key) = var.ssc_cbrid_tag_value } : {}
  )
}