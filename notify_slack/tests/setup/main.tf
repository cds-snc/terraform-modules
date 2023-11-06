resource "aws_sns_topic" "warning" {
  name = "warning"
}

output "sns_topic_arn" {
  value = aws_sns_topic.warning.arn
}
