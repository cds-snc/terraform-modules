output "sns_topic_success_arn" {
  value = aws_sns_topic.samwise_success.arn
}

output "sns_topic_failure_arn" {
  value = aws_sns_topic.samwise_failure.arn
}
