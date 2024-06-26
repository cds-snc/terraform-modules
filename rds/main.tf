/* # RDS Cluster
* This module will create an RDS Cluster with an optional RDS Proxy to manage connections.
*/

resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
}

###
# RDS
###

resource "aws_rds_cluster_instance" "instances" {
  count                = var.instances
  identifier           = "${var.name}-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.cluster.id
  instance_class       = var.instance_class
  engine               = var.engine
  engine_version       = var.engine_version
  db_subnet_group_name = aws_db_subnet_group.rds.name

  performance_insights_enabled = var.performance_insights_enabled

  tags = merge(local.common_tags, {
    Name = "${var.name}-instance-${count.index}"
    }
  )
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier          = local.identifier
  engine                      = var.engine
  engine_version              = var.engine_version
  database_name               = var.database_name
  final_snapshot_identifier   = "${var.name}-${random_string.random.result}"
  master_username             = var.username
  master_password             = var.password
  db_subnet_group_name        = aws_db_subnet_group.rds.name
  deletion_protection         = var.prevent_cluster_deletion
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.upgrade_immediately

  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  db_cluster_parameter_group_name     = var.db_cluster_parameter_group_name
  enabled_cloudwatch_logs_exports     = local.enabled_cloudwatch_logs_exports

  backtrack_window             = var.engine == "aurora-mysql" ? var.backtrack_window : 0
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  snapshot_identifier          = var.snapshot_identifier

  copy_tags_to_snapshot = true
  storage_encrypted     = true
  skip_final_snapshot   = var.skip_final_snapshot

  vpc_security_group_ids = local.security_group_ids

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.serverless_min_capacity + var.serverless_max_capacity <= 1 ? [] : [1]
    content {
      min_capacity = var.serverless_min_capacity
      max_capacity = var.serverless_max_capacity
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.log_exports
  ]

  tags = merge(local.common_tags, {
    Name = "${var.name}-cluster"
  })
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.name}-subnet-group"
  })
}

###
# RDS Proxy
###

resource "aws_db_proxy" "proxy" {
  count = var.use_proxy ? 1 : 0

  name                = local.proxy_name
  debug_logging       = var.proxy_debug_logging
  engine_family       = local.engine_family
  idle_client_timeout = 1800
  require_tls         = true

  role_arn               = aws_iam_role.rds_proxy[0].arn
  vpc_security_group_ids = local.security_group_ids
  vpc_subnet_ids         = var.subnet_ids

  # Default proxy authentication user
  auth {
    auth_scheme = "SECRETS"
    description = "The database connection string"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.connection_string[0].arn
  }

  # Additional proxy authentication users
  dynamic "auth" {
    for_each = var.proxy_secret_auth_arns
    content {
      auth_scheme = "SECRETS"
      description = "Additional proxy authentication"
      iam_auth    = "DISABLED"
      secret_arn  = auth.value
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-rds-proxy"
  })
}

resource "aws_db_proxy_default_target_group" "this" {
  count = var.use_proxy ? 1 : 0

  db_proxy_name = aws_db_proxy.proxy[0].name
}

resource "aws_db_proxy_target" "target" {
  count = var.use_proxy ? 1 : 0

  db_proxy_name         = aws_db_proxy.proxy[0].name
  target_group_name     = aws_db_proxy_default_target_group.this[0].name
  db_cluster_identifier = aws_rds_cluster.cluster.id
}

###
# Monitoring
###

# Security Group change events
resource "aws_db_event_subscription" "rds_sg_events_alerts" {
  count     = var.security_group_notifications_topic_arn != "" ? 1 : 0
  name      = "${var.name}-rds-sg-events"
  sns_topic = var.security_group_notifications_topic_arn

  source_type = "db-security-group"

  event_categories = [
    "configuration change",
    "failure",
  ]
}
