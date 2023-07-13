#
# Bucket policy
#
resource "aws_s3_bucket_policy" "upload_bucket" {
  for_each = toset(var.s3_upload_bucket_policy_create ? local.upload_bucket_ids : [])

  bucket = each.key
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
    resources = local.upload_bucket_arns_items
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = [local.scan_files_assume_role_arn]
    }
  }

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [local.scan_files_assume_role_arn]
    }
    actions = [
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging"
    ]
    resources = local.upload_bucket_arns_items
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
    resources = join(local.upload_bucket_arns, local.upload_bucket_arns_items)
  }
}

#
# Trigger scan when file is created
#
resource "aws_s3_bucket_notification" "s3_scan_object" {
  for_each = toset(local.upload_bucket_ids)
  bucket   = each.key

  queue {
    id        = "ScanObjectCreated"
    queue_arn = aws_sqs_queue.s3_scan_object.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
