output "sns_id" {
  description = "The name of the SNS topic."
  value       = aws_sns_topic.this.id
}

output "sns_arn" {
  description = "The ARN of the SNS topic."
  value       = aws_sns_topic.this.arn
}

output "kms_key_arn" {
  description = "KMS Key ARN used for SNS"
  value       = aws_sns_topic.this.kms_master_key_id
}
