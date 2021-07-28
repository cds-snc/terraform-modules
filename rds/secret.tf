resource "aws_secretsmanager_secret" "connection_string" {
  name = "${var.name}-${random_string.random.result}"
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "connection_string" {
  secret_id     = aws_secretsmanager_secret.connection_string.id
  secret_string = "postgres://${var.master_uname}:${var.master_pword}@${aws_rds_cluster.cluster.endpoint}/${var.database_name}"
}
