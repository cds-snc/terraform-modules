data "aws_caller_identity" "current" {}

locals {
  account_id                 = data.aws_caller_identity.current.account_id
  scan_files_assume_role_arn = var.scan_files_assume_role_create ? aws_iam_role.scan_files[0].arn : data.aws_iam_role.scan_files[0].arn
  upload_bucket_arns         = formatlist("arn:aws:s3:::%s", var.s3_upload_bucket_names)
  upload_bucket_arns_items   = formatlist("%s/*", local.upload_bucket_arns)
  upload_bucket_ids          = var.s3_upload_bucket_names

  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
}
