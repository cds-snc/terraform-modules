resource "aws_iam_role" "ipv4_blocklist" {
  name               = local.blocklist_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = local.common_tags
}

resource "aws_iam_policy" "ipv4_blocklist" {
  name   = local.blocklist_name
  path   = "/"
  policy = data.aws_iam_policy_document.combined.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ipv4_blocklist" {
  role       = aws_iam_role.ipv4_blocklist.name
  policy_arn = aws_iam_policy.ipv4_blocklist.arn
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "combined" {
  source_policy_documents = concat([
    data.aws_iam_policy_document.athena.json,
    data.aws_iam_policy_document.cloudwatch.json,
    data.aws_iam_policy_document.s3_read.json,
    data.aws_iam_policy_document.s3_write.json,
    data.aws_iam_policy_document.waf_ip_set.json,
  ])
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    sid    = "CloudWatchWriteAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.ipv4_blocklist.arn}:*",
    ]
  }
}

data "aws_iam_policy_document" "athena" {
  statement {
    sid    = "AthenaQueryAccess"
    effect = "Allow"
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryResults",
      "athena:GetQueryExecution"
    ]
    resources = [
      "arn:aws:athena:${local.region}:${local.account_id}:workgroup/${var.athena_workgroup_name}"
    ]
  }

  statement {
    sid    = "AthenaReadAccess"
    effect = "Allow"
    actions = [
      "athena:ListDatabases",
      "athena:ListTableMetadata",
      "athena:GetTableMetadata"
    ]
    resources = [
      "arn:aws:athena:${local.region}:${local.account_id}:catalog/AwsDataCatalog/database/${var.athena_database_name}",
      "arn:aws:athena:${local.region}:${local.account_id}:catalog/AwsDataCatalog/database/${var.athena_database_name}/table/*"
    ]
  }

  statement {
    sid    = "GlueReadAccess"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetTable",
      "glue:GetPartitions"
    ]
    resources = [
      "arn:aws:glue:${local.region}:${local.account_id}:catalog",
      "arn:aws:glue:${local.region}:${local.account_id}:database/${var.athena_database_name}",
      "arn:aws:glue:${local.region}:${local.account_id}:table/${var.athena_database_name}/*"
    ]
  }
}

data "aws_iam_policy_document" "s3_read" {
  statement {
    sid    = "S3ReadAccess"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
    ]
    resources = [
      local.athena_query_source_bucket_arn,
      "${local.athena_query_source_bucket_arn}/*",
      local.athena_query_results_bucket_arn,
      "${local.athena_query_results_bucket_arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "s3_write" {
  statement {
    sid    = "S3WriteAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${local.athena_query_results_bucket_arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "waf_ip_set" {
  statement {
    sid    = "WAFIPSetUpdate"
    effect = "Allow"
    actions = [
      "wafv2:GetIPSet",
      "wafv2:UpdateIPSet"
    ]
    resources = [
      aws_wafv2_ip_set.ipv4_blocklist.arn
    ]
  }
}
