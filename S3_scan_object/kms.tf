resource "aws_kms_key" "s3_scan_object_queue" {
  description         = "S3 scan objects KMS key for SQS queue encryption"
  policy              = data.aws_iam_policy_document.s3_scan_object_queue.json
  enable_key_rotation = true
  tags                = local.common_tags
}

resource "aws_kms_alias" "s3_scan_object_queue" {
  name          = "alias/s3_scan_object_queue${var.scan_queue_suffix}"
  target_key_id = aws_kms_key.s3_scan_object_queue.key_id
}

data "aws_iam_policy_document" "s3_scan_object_queue" {
  # checkov:skip=CKV_AWS_109: false-positify as `resources = ["*"]` refers to the key itself 
  # checkov:skip=CKV_AWS_111: false-positify as `resources = ["*"]` refers to the key itself 
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = [var.s3_scan_object_role_arn]
    }
  }
}