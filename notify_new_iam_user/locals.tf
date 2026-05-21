# Get the current AWS account ID and region
data "aws_caller_identity" "current" {}

locals {
  common_tags = merge(
    {
      (var.billing_tag_key) = var.billing_tag_value
      Terraform             = "true"
    },
    var.ssc_cbrid_tag_value != "" ? { (var.ssc_cbrid_tag_key) = var.ssc_cbrid_tag_value } : {}
  )
  account_id = data.aws_caller_identity.current.account_id
  region     = "us-east-1"
}
