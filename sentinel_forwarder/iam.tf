resource "aws_iam_role" "sentinel_forwarder_lambda" {
  name               = "SentinelForwarderLambda-${var.function_name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_policy" "sentinel_forwarder_lambda" {
  name   = "SentinelForwarderLambda-${var.function_name}"
  path   = "/"
  policy = data.aws_iam_policy_document.sentinel_forwarder_lambda.json
}

resource "aws_iam_role_policy_attachment" "sentinel_forwarder_lambda" {
  role       = aws_iam_role.sentinel_forwarder_lambda.name
  policy_arn = aws_iam_policy.sentinel_forwarder_lambda.arn
}

data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sentinel_forwarder_lambda" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.sentinel_forwarder_lambda.arn
    ]
  }
}

resource "aws_iam_policy" "sentinel_forwarder_lambda_s3" {
  for_each = length(var.s3_sources) == 0 ? [] : [true]

  name   = "SentinelForwarderLambdaS3-${var.function_name}"
  path   = "/"
  policy = data.aws_iam_policy_document.sentinel_forwarder_lambda_s3.json
}

resource "aws_iam_role_policy_attachment" "sentinel_forwarder_lambda_s3" {
  for_each = length(var.s3_sources) == 0 ? [] : [true]

  role       = aws_iam_role.sentinel_forwarder_lambda.name
  policy_arn = aws_iam_policy.sentinel_forwarder_lambda_s3.arn
}

data "aws_iam_policy_document" "sentinel_forwarder_lambda_s3" {
  for_each = length(var.s3_sources) == 0 ? [] : [true]

  statement {
    sid = "1"

    actions   = ["s3:ListBucket"]
    resources = [for obj in var.s3_sources : obj.bucket_arn]

  }

  statement {
    sid = "2"

    actions   = ["s3:GetObject"]
    resources = [for obj in var.s3_sources : "${obj.bucket_arn}/*"]
  }

  statement {
    sid = "3"

    actions   = ["kms:decrypt"]
    resources = [for obj in var.s3_sources : obj.kms_key_arn]
  }
}
