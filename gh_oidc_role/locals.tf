
locals {
  common_tags = merge(
    {
      (var.billing_tag_key) = var.billing_tag_value
      Terraform             = "true"
    },
    var.ssc_cbrid_tag_value != "" ? { (var.ssc_cbrid_tag_key) = var.ssc_cbrid_tag_value } : {}
  )
  gh_url  = "https://${local.gh_path}"
  gh_path = "token.actions.githubusercontent.com"

}

