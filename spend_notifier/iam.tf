data "aws_iam_policy_document" "spend_notifier_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
      "lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "spend_notifier" {
  name               = "spend_notifier_lambda"
  assume_role_policy = data.aws_iam_policy_document.spend_notifier_role.json

  tags = local.common_tags
}

data "aws_iam_policy_document" "spend_notifier" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:ca-central-1:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/spend_notifier:*"
    ]

  }

  statement {
    effect    = "Allow"
    actions   = ["ce:GetCostAndUsage"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "spend_notifier" {
  name   = "spend_notifier"
  policy = data.aws_iam_policy_document.spend_notifier.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "spend_notifier" {
  role       = aws_iam_role.spend_notifier.name
  policy_arn = aws_iam_policy.spend_notifier.arn
}

data "aws_iam_policy" "org_read_only" {
  arn = "arn:aws:iam::aws:policy/AWSOrganizationsReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "org_read_only" {
  role       = aws_iam_role.spend_notifier.name
  policy_arn = data.aws_iam_policy.org_read_only.arn
}

data "aws_iam_policy" "lambda_insights" {
  name = "CloudWatchLambdaInsightsExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "lambda_insights" {
  role       = aws_iam_role.spend_notifier.name
  policy_arn = data.aws_iam_policy.lambda_insights.arn
}
