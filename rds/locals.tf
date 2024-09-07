data "aws_region" "current" {}

locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }

  identifier    = "${var.name}-cluster"
  is_mysql      = var.engine == "aurora-mysql"
  database_port = local.is_mysql ? 3306 : 5432
  engine_family = local.is_mysql ? "MYSQL" : "POSTGRESQL"
  proxy_name    = "${var.name}-proxy"
  region        = data.aws_region.current.name

  security_group_desc_target = var.use_proxy ? "proxy" : "application"
  security_group_ids         = distinct(concat([aws_security_group.rds.id], var.security_group_ids))
  security_group_name        = var.use_proxy ? "${var.name}_rds_proxy_sg" : "${var.name}_rds_sg"

  # Configure the database logs that are exported to CloudWatch.  Default to none for MySQL and `postgresql` for Postgres if no values are specified
  enabled_cloudwatch_logs_exports = length(var.enabled_cloudwatch_logs_exports) > 0 ? var.enabled_cloudwatch_logs_exports : (local.is_mysql ? [] : ["postgresql"])
}
