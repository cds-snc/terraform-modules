resource "aws_iam_role" "sentinel_forwarder_lambda" {
  name               = "SentinelForwarderLambda-${var.function_name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json

  tags = local.common_tags
}

resource "aws_iam_policy" "sentinel_forwarder_lambda" {
  name   = "SentinelForwarderLambda-${var.function_name}"
  path   = "/"
  policy = data.aws_iam_policy_document.sentinel_forwarder_lambda.json

  tags = local.common_tags
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
      "${aws_cloudwatch_log_group.sentinel_forwarder_lambda.arn}:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries"
    ]
    resources = [
      "*"
    ]
  }

  # Only when a parameter exists to read. The secretless v2 path creates none,
  # and a statement with an empty resource list is invalid.
  dynamic "statement" {
    for_each = local.has_secrets ? [1] : []

    content {
      effect = "Allow"
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
      ]
      resources = [
        aws_ssm_parameter.sentinel_forwarder_auth[0].arn
      ]
    }
  }
}

# The whole credential on the secretless path: the layer calls this to mint the
# OIDC token it presents to Entra as a client assertion. Scoped to the one pool,
# which has to be in this account.
#
# Its own role policy rather than another statement in the base document, for
# two reasons. It shows up in a plan as a named resource instead of a diff
# inside a policy JSON blob, and it is inline on the role, so it cannot be
# stripped by — or strip — the attached base policy.
resource "aws_iam_role_policy" "sentinel_forwarder_cognito" {
  count = var.cognito_identity_pool_id != "" ? 1 : 0

  name   = "SentinelForwarderCognito-${var.function_name}"
  role   = aws_iam_role.sentinel_forwarder_lambda.name
  policy = data.aws_iam_policy_document.sentinel_forwarder_cognito[0].json
}

data "aws_iam_policy_document" "sentinel_forwarder_cognito" {
  count = var.cognito_identity_pool_id != "" ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "cognito-identity:GetOpenIdTokenForDeveloperIdentity",
    ]
    resources = [
      local.cognito_pool_arn
    ]
  }
}

resource "aws_iam_policy" "sentinel_forwarder_lambda_s3" {
  count = length(var.s3_sources) == 0 ? 0 : 1

  name   = "SentinelForwarderLambdaS3-${var.function_name}"
  path   = "/"
  policy = data.aws_iam_policy_document.sentinel_forwarder_lambda_s3[0].json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "sentinel_forwarder_lambda_s3" {
  count = length(var.s3_sources) == 0 ? 0 : 1

  role       = aws_iam_role.sentinel_forwarder_lambda.name
  policy_arn = aws_iam_policy.sentinel_forwarder_lambda_s3[0].arn
}

data "aws_iam_policy_document" "sentinel_forwarder_lambda_s3" {
  count = length(var.s3_sources) == 0 ? 0 : 1

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
