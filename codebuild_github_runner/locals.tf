
locals {
  is_github_codeconnection = var.github_codeconnection_name != ""
  is_github_pat            = var.github_personal_access_token != ""
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
}

