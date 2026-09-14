
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  is_github_codeconnection = var.github_codeconnection_name != ""
  is_github_pat            = var.github_personal_access_token != ""
  is_vpc_config            = var.vpc_id != "" && length(var.subnet_ids) > 0 && length(var.security_group_ids) > 0
  common_tags = merge(
    {
      (var.billing_tag_key) = var.billing_tag_value
      Terraform             = "true"
    },
    var.ssc_cbrid_tag_value != "" ? { (var.ssc_cbrid_tag_key) = var.ssc_cbrid_tag_value } : {}
  )
}

