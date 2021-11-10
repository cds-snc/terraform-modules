data "aws_iam_policy_document" "service_principal" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.service_principal.json
  tags               = local.common_tags
}

### Lambda Insights
data "aws_iam_policy" "lambda_insights" {
  count = var.enable_lambda_insights ? 1 : 0
  name  = "CloudWatchLambdaInsightsExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "lambda_insights" {
  count      = var.enable_lambda_insights ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.lambda_insights[0].arn
}

### Policies
resource "aws_iam_policy" "policies" {
  count  = length(var.policies)
  name   = "${var.name}-${count.index}"
  path   = "/"
  policy = var.policies[count.index]
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "attachments" {
  count      = length(aws_iam_policy.policies.*.arn)
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.policies[count.index].arn
}

# Use AWS managed IAM policy
####
# Provides minimum permissions for a Lambda function to execute while
# accessing a resource within a VPC - create, describe, delete network
# interfaces and write permissions to CloudWatch Logs.
####
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
