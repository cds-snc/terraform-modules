
# Terraform code to create an Amazon DocumentDB 

# Create the DocumentDB parameter group
resource "aws_docdb_cluster_parameter_group" "this" {
  count       = var.enable ? 1 : 0
  name        = "parameter-group-${var.database_name}"
  description = "DB cluster parameter group."
  family      = var.cluster_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  tags = local.common_tags
}

# Create the DocumentDB cluster
resource "aws_docdb_cluster" "this" {
  count                           = var.enable ? 1 : 0
  cluster_identifier              = var.database_name
  master_username                 = var.master_username
  master_password                 = var.master_password
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.backup_window
  final_snapshot_identifier       = lower(var.database_name)
  apply_immediately               = var.apply_immediately
  deletion_protection             = var.deletion_protection
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.kms_key_id
  snapshot_identifier             = var.snapshot_identifier
  vpc_security_group_ids          = var.vpc_security_group_ids
  db_subnet_group_name            = aws_docdb_subnet_group.this[0].name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.this[0].name
  engine                          = var.engine
  engine_version                  = var.engine_version

  tags = local.common_tags

  depends_on = [aws_docdb_cluster_parameter_group.this]
}

# DocumentDB instance
resource "aws_docdb_cluster_instance" "this" {
  count              = var.enable ? var.cluster_size : 0
  identifier         = "${var.database_name}-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.this[0].id
  apply_immediately  = var.apply_immediately
  engine             = var.instance_engine
  instance_class     = var.instance_class

  tags = local.common_tags
}

# DocumentDB subnet group
resource "aws_docdb_subnet_group" "this" {
  count       = var.enable ? 1 : 0
  name        = "subnet-group-${var.database_name}"
  description = "DB subnet group for the DB Cluster instances."
  subnet_ids  = var.subnet_ids
  tags        = local.common_tags
}