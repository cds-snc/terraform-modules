resource "aws_rds_cluster_parameter_group" "audit_logging" {
  name        = "audit-logging-aurora-mysql57"
  family      = "aurora-mysql5.7"
  description = "RDS cluster parameter group"

  parameter {
    name  = "server_audit_logging"
    value = "1"
  }

  parameter {
    name  = "server_audit_events"
    value = "CONNECT,QUERY_DCL,QUERY_DDL,QUERY_DML"
  }
}