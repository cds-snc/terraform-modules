resource "aws_cloudwatch_log_group" "proxy" {
  name              = "/aws/rds/proxy/${local.proxy_name}"
  retention_in_days = var.proxy_log_retention_in_days

  tags = merge(local.common_tags, {
    Name = "${var.name}_proxy_logs"
  })
}

resource "aws_cloudwatch_log_group" "log_exports" {
  for_each = toset(local.enabled_cloudwatch_logs_exports)

  name              = "/aws/rds/cluster/${local.identifier}/${each.value}"
  retention_in_days = 30

  tags = merge(local.common_tags, {
    Name = "${var.name}-cluster"
  })
}
