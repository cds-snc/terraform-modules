output "client_vpn_security_group_id" {
  description = "Client VPN's security group ID"
  value       = aws_security_group.this.id
}