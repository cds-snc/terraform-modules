
locals {
  is_athena_enabled = var.athena_workgroup_name != "" && var.athena_database_name != ""
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
}

