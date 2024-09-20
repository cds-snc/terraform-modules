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
    data.aws_iam_policy_document.cloudwatch_policy.json,
    data.aws_iam_policy_document.s3.json
  ])
}

data "aws_iam_policy_document" "cloudwatch_policy" {
  statement {
    sid    = "CloudWatchAccess"
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
    effect = "Allow"
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryResults",
      "athena:GetQueryExecution"
    ]
    resources = [
      "arn:aws:athena:${local.region}:${local.account_id}:workgroup/default"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "athena:ListDatabases",
      "athena:ListTableMetadata",
      "athena:GetTableMetadata"
    ]
    resources = [
      "arn:aws:athena:${local.region}:${local.account_id}:catalog/AwsDataCatalog/database/${var.athena_database_name}",
      "arn:aws:athena:${local.region}:${local.account_id}:catalog/AwsDataCatalog/database/${var.athena_database_name}/table/${var.athena_waf_table_name}"
    ]
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      local.athena_query_results_bucket_arn,
      "${local.athena_query_results_bucket_arn}/*",
    ]
  }
}
