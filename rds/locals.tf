locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }

  is_mysql           = var.engine == "aurora-mysql"
  database_port      = local.is_mysql ? 3306 : 5432
  engine_family      = local.is_mysql ? "MYSQL" : "POSTGRESQL"
  security_group_ids = distinct(concat([aws_security_group.rds_proxy.id], var.security_group_ids))
}
