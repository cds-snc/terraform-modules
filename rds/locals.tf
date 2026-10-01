data "aws_region" "current" {}

locals {
  common_tags = merge(
    {
      (var.billing_tag_key) = var.billing_tag_value
      Terraform             = "true"
    },
    var.ssc_cbrid_tag_value != "" ? { (var.ssc_cbrid_tag_key) = var.ssc_cbrid_tag_value } : {}
  )

  identifier    = "${var.name}-cluster"
  is_mysql      = var.engine == "aurora-mysql"
  database_port = local.is_mysql ? 3306 : 5432
  engine_family = local.is_mysql ? "MYSQL" : "POSTGRESQL"
  proxy_name    = "${var.name}-proxy"
  region        = data.aws_region.current.name

  use_proxy_iam_authentication = var.use_proxy && var.proxy_iam_authentication_enabled
  use_proxy_secret_auth        = var.use_proxy && !var.proxy_iam_authentication_enabled

  proxy_iam_authentication_users = local.use_proxy_iam_authentication ? var.proxy_iam_authentication_task_role_arns : {}
  proxy_iam_authentication_task_roles = {
    for task_role in flatten([
      for database_username, task_role_arns in local.proxy_iam_authentication_users : [
        for task_role_arn in task_role_arns : {
          database_username = database_username
          task_role_arn     = task_role_arn
        }
      ]
      ]) : "${task_role.database_username}:${task_role.task_role_arn}" => {
      database_username = task_role.database_username
      task_role_name    = element(reverse(split("/", task_role.task_role_arn)), 0)
    }
  }

  rds_db_resource_arn_prefix = replace(join(":", slice(split(":", aws_rds_cluster.cluster.arn), 0, 5)), ":rds:", ":rds-db:")
  proxy_resource_id          = var.use_proxy ? element(reverse(split(":", aws_db_proxy.proxy[0].arn)), 0) : null

  security_group_desc_target = var.use_proxy ? "proxy" : "application"
  security_group_ids         = distinct(concat([aws_security_group.rds.id], var.security_group_ids))
  security_group_name        = var.use_proxy ? "${var.name}_rds_proxy_sg" : "${var.name}_rds_sg"

  # Configure the database logs that are exported to CloudWatch.  Default to none for MySQL and `postgresql` for Postgres if no values are specified
  enabled_cloudwatch_logs_exports = length(var.enabled_cloudwatch_logs_exports) > 0 ? var.enabled_cloudwatch_logs_exports : (local.is_mysql ? [] : ["postgresql"])

  # Tags required on IAM, Secrets Manager, CloudWatch, and VPC resources
  cbrid_tags = {
    ssc_cbrid = "22DH"
  }
}
