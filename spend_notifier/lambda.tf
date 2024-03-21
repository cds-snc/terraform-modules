### Replace this with a tf module when I build it


data "archive_file" "spend_notifier" {
  type        = "zip"
  source_file = "${path.module}/lambdas/spend_notifier/spend_notifier.js"
  output_path = "/tmp/main.py.zip"
}

resource "aws_lambda_function" "spend_notifier" {
  function_name = "spend_notifier"
  role          = aws_iam_role.spend_notifier.arn
  runtime       = "nodejs16.x"
  handler       = "spend_notifier.handler"
  memory_size   = 512

  filename         = data.archive_file.spend_notifier.output_path
  source_code_hash = filebase64sha256(data.archive_file.spend_notifier.output_path)
  tracing_config {
    mode = "PassThrough"
  }

  timeout = 30

  tags = local.common_tags
}


resource "aws_lambda_permission" "allow_daily_budget" {
  statement_id  = "AllowDailyBudget"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.spend_notifier.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_budget_spend.arn
}

resource "aws_lambda_permission" "allow_weekly_budget" {
  statement_id  = "AllowWeeklyBudget"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.spend_notifier.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.weekly_budget_spend.arn
}


resource "aws_cloudwatch_log_group" "this" {
  #checkov:skip=CKV_AWS_158:We trust the AWS provided keys
  name              = "/aws/lambda/${aws_lambda_function.spend_notifier.function_name}"
  retention_in_days = "14"
  tags              = local.common_tags
}