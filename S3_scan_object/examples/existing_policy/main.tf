module "existing_policy" {
  source = "../../"

  s3_upload_bucket_names         = [module.upload_bucket.s3_bucket_id]
  s3_upload_bucket_policy_create = false
  billing_tag_value              = "terratest"
}

resource "random_id" "upload_bucket" {
  byte_length = 4
}

module "upload_bucket" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v9.6.8"
  bucket_name       = "an-existing-upload-bucket-${random_id.upload_bucket.hex}"
  billing_tag_value = "terratest"

  versioning = {
    enabled = true
  }
}

#
# Bucket policy that allows the lambda function to add object tags
# You would create your own policy if your upload bucket has existing
# policy that you needed to keep in place.
#
resource "aws_s3_bucket_policy" "upload_bucket" {
  bucket = module.upload_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.upload_bucket.json
}

data "aws_iam_policy_document" "upload_bucket" {
  source_policy_documents = [
    data.aws_iam_policy_document.limit_tagging.json,
    data.aws_iam_policy_document.scan_files_download.json
  ]
}

#
# Only allow the lambda to add object tags
# to upload bucket
#
data "aws_iam_policy_document" "limit_tagging" {
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
      "${module.upload_bucket.s3_bucket_arn}/*"
    ]
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = [module.existing_policy.scan_files_assume_role_arn]
    }
  }

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [module.existing_policy.scan_files_assume_role_arn]
    }
    actions = [
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging"
    ]
    resources = [
      "${module.upload_bucket.s3_bucket_arn}/*"
    ]
  }
}

#
# Allow Scan Files to download objects
#
data "aws_iam_policy_document" "scan_files_download" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [module.existing_policy.scan_files_assume_role_arn]
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
      module.upload_bucket.s3_bucket_arn,
      "${module.upload_bucket.s3_bucket_arn}/*"
    ]
  }
}
