#
# Bucket policy
#
resource "aws_s3_bucket_policy" "upload_bucket" {
  count  = var.s3_upload_bucket_policy_create ? length(local.upload_buckets) : 0
  bucket = local.upload_buckets[count.index].id
  policy = data.aws_iam_policy_document.upload_bucket[count.index].json
}

data "aws_iam_policy_document" "upload_bucket" {
  count = var.s3_upload_bucket_policy_create ? length(local.upload_buckets) : 0
  source_policy_documents = [
    data.aws_iam_policy_document.limit_tagging[count.index].json,
    data.aws_iam_policy_document.scan_files_download[count.index].json
  ]
}

#
# Only allow the lambda to add object tags
# to upload bucket
#
data "aws_iam_policy_document" "limit_tagging" {
  count = var.s3_upload_bucket_policy_create ? length(local.upload_buckets) : 0

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
    resources = [local.upload_buckets[count.index].arn_items]
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
    resources = [local.upload_buckets[count.index].arn_items]
  }
}

#
# Allow Scan Files to download objects
#
data "aws_iam_policy_document" "scan_files_download" {
  count = var.s3_upload_bucket_policy_create ? length(local.upload_buckets) : 0

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
      local.upload_buckets[count.index].arn,
      local.upload_buckets[count.index].arn_items
    ]
  }
}

#
# Trigger scan when file is created
#
resource "aws_s3_bucket_notification" "s3_scan_object" {
  count  = length(local.upload_buckets)
  bucket = local.upload_buckets[count.index].id

  queue {
    id        = "ScanObjectCreated"
    queue_arn = aws_sqs_queue.s3_scan_object.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
