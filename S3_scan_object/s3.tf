#
# Upload bucket
#
module "upload_bucket" {
  count             = var.s3_upload_bucket_create ? 1 : 0
  source            = "github.com/cds-snc/terraform-modules?ref=v2.0.5//S3"
  bucket_name       = var.s3_upload_bucket_name != null ? var.s3_upload_bucket_name : "s3-scan-object-${var.product_name}"
  billing_tag_value = var.billing_tag_value

  versioning = {
    enabled = true
  }
}

#
# Bucket policy
#
resource "aws_s3_bucket_policy" "upload_bucket" {
  count  = var.s3_upload_bucket_policy_create ? 1 : 0
  bucket = local.upload_bucket_id
  policy = data.aws_iam_policy_document.upload_bucket[0].json
}

data "aws_iam_policy_document" "upload_bucket" {
  count = var.s3_upload_bucket_policy_create ? 1 : 0
  source_policy_documents = [
    data.aws_iam_policy_document.limit_tagging[0].json,
    data.aws_iam_policy_document.scan_files_download[0].json
  ]
}

#
# Only allow the lambda to add object tags
# to upload bucket
#
data "aws_iam_policy_document" "limit_tagging" {
  count = var.s3_upload_bucket_policy_create ? 1 : 0

  statement {
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersionTagging",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging"
    ]
    resources = [
      "${local.upload_bucket_arn}/*"
    ]
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = [module.s3_scan_object.function_role_arn]
    }
  }

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [module.s3_scan_object.function_role_arn]
    }
    actions = [
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging"
    ]
    resources = [
      "${local.upload_bucket_arn}/*"
    ]
  }
}

#
# Allow Scan Files to download objects
#
data "aws_iam_policy_document" "scan_files_download" {
  count = var.s3_upload_bucket_policy_create ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [local.scan_files_assume_role_arn]
    }
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging"
    ]
    resources = [
      local.upload_bucket_arn,
      "${local.upload_bucket_arn}/*"
    ]
  }
}

#
# Trigger scan when file is created
#
resource "aws_lambda_permission" "s3_execute" {
  statement_id  = "S3ScanObjectS3Invoke-${var.product_name}"
  action        = "lambda:InvokeFunction"
  principal     = "s3.amazonaws.com"
  function_name = module.s3_scan_object.function_name
  source_arn    = local.upload_bucket_arn
}

resource "aws_s3_bucket_notification" "s3_scan_object" {
  bucket = local.upload_bucket_id

  lambda_function {
    lambda_function_arn = module.s3_scan_object.function_arn
    id                  = "ScanObjectCreated"
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.s3_execute]
}
