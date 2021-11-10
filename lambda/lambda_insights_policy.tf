
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
