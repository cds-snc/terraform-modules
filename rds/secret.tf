resource "aws_secretsmanager_secret" "connection_string" {
  name = "${var.name}-${random_string.random.result}"
  tags = local.common_tags
}

// Secret format grabbed from here: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/rds-proxy.html#rds-proxy-secrets-arns
resource "aws_secretsmanager_secret_version" "connection_string" {
  secret_id     = aws_secretsmanager_secret.connection_string.id
  secret_string = "{'username':'${var.username}','password':'${var.password}'}"
}

resource "aws_secretsmanager_secret" "proxy_connection_string" {
  name = "${var.name}-${random_string.random.result}-proxy-connection-string"
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "proxy_connection_string" {
  secret_id     = aws_secretsmanager_secret.proxy_connection_string.id
  secret_string = "postgresql://${var.username}:${var.password}@${aws_db_proxy.proxy.endpoint}/${var.database_name}"
}
