data "aws_caller_identity" "current" {}

locals {
  account_id                 = data.aws_caller_identity.current.account_id
  scan_files_assume_role_arn = var.scan_files_assume_role_create ? aws_iam_role.scan_files[0].arn : data.aws_iam_role.scan_files[0].arn
  upload_bucket_arn          = "arn:aws:s3:::${var.s3_upload_bucket_name}"
  upload_bucket_id           = var.s3_upload_bucket_name

  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
}
