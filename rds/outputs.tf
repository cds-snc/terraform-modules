output "proxy_connection_string_arn" {
  description = "The arn for the connectionstring to the RDS proxy"
  value       = aws_secretsmanager_secret.proxy_connection_string.arn
}

output "proxy_endpoint" {
  value = aws_db_proxy.proxy.endpoint
}
