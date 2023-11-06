resource "aws_sns_topic" "warning" {
  # checkov:skip=CKV_AWS_26: encryption not required for example
  name = "warning"
}

output "sns_topic_arn" {
  value = aws_sns_topic.warning.arn
}
