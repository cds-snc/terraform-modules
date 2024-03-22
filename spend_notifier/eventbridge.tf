resource "aws_cloudwatch_event_rule" "weekly_budget_spend" {
  name                = "weeklyBudgetSpend"
  schedule_expression = "cron(0 12 ? * SUN *)"

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "weekly_budget_spend" {
  rule = aws_cloudwatch_event_rule.weekly_budget_spend.name
  arn  = aws_lambda_function.spend_notifier.arn
  input = jsonencode({
    "hook" = "${var.weekly_spend_notifier_hook}"
    }
  )
}

resource "aws_cloudwatch_event_rule" "daily_budget_spend" {
  name                = "dailyBudgetSpend"
  schedule_expression = "cron(0 12 * * ? *)"

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "daily_budget_spend" {
  rule = aws_cloudwatch_event_rule.daily_budget_spend.name
  arn  = aws_lambda_function.spend_notifier.arn
  input = jsonencode({
    "hook" = "${var.daily_spend_notifier_hook}"
  })
}