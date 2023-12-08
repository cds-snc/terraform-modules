locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Source                = "cds-snc/terraform-modules/client_vpn"
    Terraform             = "true"
  }
  dns_host        = cidrhost(var.vpc_cidr_block, 2)
  is_self_service = var.self_service_portal == "enabled"
}
