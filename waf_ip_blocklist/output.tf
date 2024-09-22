output "ipv4_blocklist_arn" {
  description = "The ARN of the IP blocklist"
  value       = aws_wafv2_ip_set.ipv4_blocklist.arn
}

output "ipv4_lambda_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for the IPv4 blocklist Lambda"
  value       = aws_cloudwatch_log_group.ipv4_blocklist.arn
}

output "ipv4_lambda_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for the IPv4 blocklist Lambda"
  value       = aws_cloudwatch_log_group.ipv4_blocklist.name
}
