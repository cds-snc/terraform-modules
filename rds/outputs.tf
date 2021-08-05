output "proxy_connection_string_arn" {
  description = "The arn for the connectionstring to the RDS proxy"
  value       = aws_secretsmanager_secret.proxy_connection_string.arn
}

output "proxy_connection_string_value" {
  value     = aws_secretsmanager_secret_version.proxy_connection_string.secret_string
  sensitive = true
}

output "proxy_endpoint" {
  value = aws_db_proxy.proxy.endpoint
}

output "proxy_security_group_id" {
  value = aws_security_group.rds_proxy.id
}

output "proxy_security_group_arn" {
  value = aws_security_group.rds_proxy.arn
}
