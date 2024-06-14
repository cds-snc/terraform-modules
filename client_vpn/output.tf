output "client_vpn_cloudwatch_log_group_name" {
  description = "Client VPN's CloudWatch log group name"
  value       = aws_cloudwatch_log_group.this.name
}

output "client_vpn_security_group_id" {
  description = "Client VPN's security group ID"
  value       = aws_security_group.this.id
}

output "client_vpn_private_key_pem" {
  description = "Client VPN's private key PEM"
  value       =  var.authentication_option == "certificate-authentication" ? tls_private_key.client_vpn[0].private_key_pem : null
  sensitive   = true
}

output "client_vpn_certificate_pem" {
  description = "Client VPN's certificate PEM"
  value       =  var.authentication_option == "certificate-authentication" ? tls_private_key.client_vpn[0].private_key_pem : null
  sensitive   = true
}