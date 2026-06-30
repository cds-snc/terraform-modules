#
# IAM roles and policies for CloudWatch log subscription and Kinesis Firehose
#
resource "aws_iam_role" "cloudwatch_log_storage" {
  name               = "${var.product_name}-cloudwatch-log-storage"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_log_storage_assume.json
}

resource "aws_iam_role_policy" "cloudwatch_log_storage" {
  name   = "${var.product_name}-cloudwatch-log-storage"
  role   = aws_iam_role.cloudwatch_log_storage.id
  policy = data.aws_iam_policy_document.cloudwatch_log_storage.json
}

data "aws_iam_policy_document" "cloudwatch_log_storage_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_log_storage" {
  statement {
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.cloudwatch_log_storage.arn
    ]
  }
}

resource "aws_iam_role" "firehose_cloudwatch_log_storage" {
  name               = "${var.product_name}-firehose-cloudwatch-log-storage"
  assume_role_policy = data.aws_iam_policy_document.firehose_cloudwatch_log_storage_assume.json
}

resource "aws_iam_role_policy" "firehose_cloudwatch_log_storage" {
  name   = "${var.product_name}-firehose-cloudwatch-log-storage"
  role   = aws_iam_role.firehose_cloudwatch_log_storage.id
  policy = data.aws_iam_policy_document.firehose_cloudwatch_log_storage.json
}

data "aws_iam_policy_document" "firehose_cloudwatch_log_storage_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "firehose_cloudwatch_log_storage" {
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      module.cloudwatch_log_storage.s3_bucket_arn,
      "${module.cloudwatch_log_storage.s3_bucket_arn}/*"
    ]
  }
}
