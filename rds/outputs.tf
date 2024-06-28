output "rds_cluster_arn" {
  description = "The ARN of the RDS cluster."
  value       = aws_rds_cluster.cluster.arn
}

output "rds_cluster_id" {
  description = "The ID of the RDS cluster."
  value       = aws_rds_cluster.cluster.id
}

output "rds_cluster_endpoint" {
  description = "RDS cluster read/write connection endpoint."
  value       = aws_rds_cluster.cluster.endpoint
}

output "proxy_connection_string_arn" {
  description = "The ARN for the connection string to the RDS proxy."
  value       = var.use_proxy ? aws_secretsmanager_secret.proxy_connection_string[0].arn : null
}

output "proxy_connection_string_value" {
  description = "The string value of the RDS proxy connection string.  This includes the username and password."
  value       = var.use_proxy ? aws_secretsmanager_secret_version.proxy_connection_string[0].secret_string : null
  sensitive   = true
}

output "proxy_endpoint" {
  description = "The RDS proxy read/write connection endpoint."
  value       = var.use_proxy ? aws_db_proxy.proxy[0].endpoint : null
}

output "proxy_security_group_id" {
  description = "The RDS proxy security group ID."
  value       = var.use_proxy ? aws_security_group.rds.id : null
}

output "proxy_security_group_arn" {
  description = "The RDS proxy security group ARN."
  value       = var.use_proxy ? aws_security_group.rds.arn : null
}

output "cluster_security_group_id" {
  description = "The RDS cluster security group ID."
  value       = aws_security_group.rds.id
}

output "cluster_security_group_arn" {
  description = "The RDS cluster security group ID."
  value       = aws_security_group.rds.arn
}
