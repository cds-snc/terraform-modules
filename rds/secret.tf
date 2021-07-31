resource "aws_secretsmanager_secret" "connection_string" {
  name = "${var.name}-${random_string.random.result}"
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "connection_string" {
  secret_id     = aws_secretsmanager_secret.connection_string.id
  secret_string = "postgres://${var.username}:${var.password}@${aws_rds_cluster.cluster.endpoint}/${var.database_name}"
}

resource "aws_secretsmanager_secret" "proxy_connection_string" {
  name = "${var.name}-${random_string.random.result}-proxy-connection-string"
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "proxy_connection_string" {
  secret_id     = aws_secretsmanager_secret.proxy_connection_string.id
  secret_string = "postgres://${var.username}:${var.password}@${aws_db_proxy.proxy.endpoint}/${var.database_name}"
}
