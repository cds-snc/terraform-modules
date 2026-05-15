locals {
  common_tags = merge(
    {
      (var.billing_tag_key) = var.billing_tag_value
      Source                = "cds-snc/terraform-modules/client_vpn"
      Terraform             = "true"
    },
    var.ssc_cbrid_tag_value != "" ? { (var.ssc_cbrid_tag_key) = var.ssc_cbrid_tag_value } : {}
  )
  dns_host        = cidrhost(var.vpc_cidr_block, 2)
  is_self_service = var.self_service_portal == "enabled"
}
