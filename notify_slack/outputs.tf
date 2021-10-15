output "lambda_arn" {
  description = "ARN of the Lambda function that creates the Slack message"
  value       = aws_lambda_function.notify_slack.arn
}
