
locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
  lambda_ecr_arn   = var.create_ecr_repository ? aws_ecr_repository.this[0].arn : var.lambda_ecr_arn
  lambda_image_uri = "${var.create_ecr_repository ? aws_ecr_repository.this[0].repository_url : var.lambda_image_uri}:${var.lambda_image_tag}"
  policies         = var.s3_arn_write_path != null ? concat(var.lambda_policies, [data.aws_iam_policy_document.s3_write[0].json]) : var.lambda_policies
}
