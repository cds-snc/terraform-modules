output "gha_vpn_cloudwatch_log_group_name" {
  description = "Github Action VPN's CloudWatch log group name"
  value       = aws_cloudwatch_log_group.this.name
}

output "gha_vpn_security_group_id" {
  description = "Github Action VPN's security group ID"
  value       = aws_security_group.this.id
}

output "gha_vpn_private_key_pem" {
  description = "Github Action VPN's private key PEM"
  value       = tls_private_key.gha_vpn.private_key_pem
  sensitive   = true
}

output "gha_vpn_certificate_pem" {
  description = "Github Action VPN's certificate PEM"
  value       = tls_self_signed_cert.gha_vpn.cert_pem
  sensitive   = true
}
