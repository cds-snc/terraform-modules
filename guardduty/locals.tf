
locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }

  # tags = merge(var.tags, common_tags)
}

