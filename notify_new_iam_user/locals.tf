# Get the current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}
