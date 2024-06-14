output "client_vpn_cloudwatch_log_group_name" {
  description = "Client VPN's CloudWatch log group name"
  value       = aws_cloudwatch_log_group.this.name
}

output "client_vpn_security_group_id" {
  description = "Client VPN's security group ID"
  value       = aws_security_group.this.id
}