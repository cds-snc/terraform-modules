data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id    = data.aws_caller_identity.current.account_id
  athena_region = var.athena_region != "" ? var.athena_region : data.aws_region.current.name
}