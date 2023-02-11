resource "aws_iam_role" "disable_exposed_iam_credential_lambda" {
  name               = "DisableExposedIAMCredentialLambda-${var.function_name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_policy" "disable_exposed_iam_credential_lambda" {
  name   = "DisableExposedIAMCredentialLambda-${var.function_name}"
  path   = "/"
  policy = data.aws_iam_policy_document.disable_exposed_iam_credential_lambda.json
}

resource "aws_iam_role_policy_attachment" "disable_exposed_iam_credential_lambda" {
  role       = aws_iam_role.disable_exposed_iam_credential_lambda.name
  policy_arn = aws_iam_policy.disable_exposed_iam_credential_lambda.arn
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

data "aws_iam_policy_document" "disable_exposed_iam_credential_lambda" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.disable_exposed_iam_credential_lambda.arn}:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GetAccessKeyLastUsed",
      "iam:UpdateAccessKey",
    ]
    resources = [
      "*"
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
}
