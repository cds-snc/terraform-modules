locals {
  common_tags = {
    (var.billing_tag_key)  = var.billing_tag_value
    Terraform              = "true"
    (var.critical_tag_key) = var.critical_tag_value ? "true" : "false"
  }
}
