# MySQL Database cluster with two instances and audit logs exported to CloudWatch
module "mysql_cluster" {
  source = "../../"
  name   = "mysql"

  database_name  = "terratest_mysql"
  engine         = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.11.2"
  instances      = 2
  instance_class = "db.t3.small"
  username       = "thebigcheese"
  password       = "pasword123"

  # Enable audit logging
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.enable_audit_logging.name
  enabled_cloudwatch_logs_exports = ["audit"]

  # These two settings are not recommended for prod, but required by our
  # Terratests so they can properly destroy resources once finished.
  prevent_cluster_deletion = false
  skip_final_snapshot      = true

  # Required to use `db.t3.small` instances for MySQL
  performance_insights_enabled = false

  backup_retention_period = 1
  preferred_backup_window = "01:00-03:00"

  vpc_id     = module.mysql_cluster_vpc.vpc_id
  subnet_ids = module.mysql_cluster_vpc.private_subnet_ids

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Terratest"
}

resource "aws_rds_cluster_parameter_group" "enable_audit_logging" {
  name        = "terratest-aurora-mysql57"
  family      = "aurora-mysql5.7"
  description = "RDS cluster parameter group"

  parameter {
    name  = "server_audit_logging"
    value = "1"
  }

  # Available events: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Auditing.html#AuroraMySQL.Auditing.Enable.server_audit_events
  parameter {
    name  = "server_audit_events"
    value = "CONNECT,QUERY_DCL,QUERY_DDL,QUERY_DML"
  }
}

# At least 2 subnets are required by the RDS proxy
module "mysql_cluster_vpc" {
  source = "../../../vpc/"
  name   = "mysql-cluster"

  high_availability = true
  enable_flow_log   = false
  block_ssh         = true
  block_rdp         = true
  enable_eip        = false

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Terratest"
}

output "rds_cluster_id" {
  value = module.mysql_cluster.rds_cluster_id
}

output "vpc_id" {
  value = module.mysql_cluster_vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.mysql_cluster_vpc.private_subnet_ids
}
