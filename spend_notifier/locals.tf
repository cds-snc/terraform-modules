locals {
  common_tags = {
    CostCentre = var.billing_tag_value
    Terraform  = "true"
  }
}