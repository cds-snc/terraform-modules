/* RDS Postgresql Cluster
* This module will create an RDS Postgresql Cluster behind an RDS Proxy to manage connections.
*/

resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
}

###
# RDS
###

locals {
  engine = "aurora-postgresql"
}

resource "aws_rds_cluster_instance" "instances" {
  count                = var.instances
  identifier           = "${var.name}-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.cluster.id
  instance_class       = var.instance_class
  engine               = local.engine
  engine_version       = var.engine_version
  db_subnet_group_name = aws_db_subnet_group.rds.name

  performance_insights_enabled = true

  tags = merge(local.common_tags, {
    Name = "${var.name}-instance-${count.index}"
    }
  )

}


resource "aws_rds_cluster" "cluster" {
  cluster_identifier          = "${var.name}-cluster"
  engine                      = local.engine
  engine_version              = var.engine_version
  database_name               = var.database_name
  final_snapshot_identifier   = "${var.name}-${random_string.random.result}"
  master_username             = var.username
  master_password             = var.password
  backup_retention_period     = var.backup_retention_period
  preferred_backup_window     = var.preferred_backup_window
  db_subnet_group_name        = aws_db_subnet_group.rds.name
  deletion_protection         = var.prevent_cluster_deletion
  allow_major_version_upgrade = var.allow_major_version_upgrade

  # Ignore TFSEC rule as we are using managed KMS
  storage_encrypted = true #tfsec:ignore:AWS051


  vpc_security_group_ids = var.sg_ids

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

locals {
  proxy_name = "${var.name}-proxy"
}

resource "aws_db_proxy" "proxy" {
  name                = local.proxy_name
  debug_logging       = var.proxy_debug_logging
  engine_family       = "POSTGRESQL"
  idle_client_timeout = 1800
  require_tls         = true

  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_security_group_ids = var.sg_ids
  vpc_subnet_ids         = var.subnet_ids

  auth {
    auth_scheme = "SECRETS"
    description = "The postgresql connection string"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.connection_string.arn
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-rds-proxy"
  })
}


resource "aws_security_group" "rds_to_proxy" {
  name        = "${var.name}_rds_proxy_sg"
  description = "Used by EFS"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.name}_rds_proxy_sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "proxy" {

  name              = "/aws/rds/proxy/${local.proxy_name}"
  retention_in_days = var.proxy_log_retention_in_days

  tags = merge(local.common_tags, {
    Name = "${var.name}_proxy_logs"
  })
}
