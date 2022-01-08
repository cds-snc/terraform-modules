
locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
  gh_url  = "https://${local.gh_path}"
  gh_path = "token.actions.githubusercontent.com"

}

