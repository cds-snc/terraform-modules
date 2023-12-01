provider "aws" {
  region = "ca-central-1"
}

variables {
  name = "postgres"

  database_name  = "postgres"
  engine         = "aurora-postgresql"
  engine_version = "15.2"
  instances      = 1
  instance_class = "db.t3.medium"
  username       = "thebigcheese2"
  password       = "pasword1234"

  backup_retention_period = 7
  preferred_backup_window = "01:00-03:00"

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery", "postgresql"]

  vpc_id     = "vpc1234"
  subnet_ids = ["subnet1234"]

}

run "postgres_cluster" {
  command = plan

  assert {
    condition     = aws_rds_cluster.cluster.cluster_identifier == "postgres-cluster"
    error_message = "Cluster identifier did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.database_name == "postgres"
    error_message = "Cluster database name did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.engine == "aurora-postgresql"
    error_message = "Cluster engine did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.engine_version == "15.2"
    error_message = "Cluster engine version did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.master_username == "thebigcheese2"
    error_message = "Cluster username did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.master_password == "pasword1234"
    error_message = "Cluster password did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.backtrack_window == 0
    error_message = "Cluster backtrack window did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.deletion_protection == true
    error_message = "Cluster deletion protection did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.storage_encrypted == true
    error_message = "Cluster storage encrypted did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.apply_immediately == false
    error_message = "Cluster apply immediately did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.skip_final_snapshot == false
    error_message = "Cluster skip final snapshot did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.copy_tags_to_snapshot == true
    error_message = "Cluster copy tags to snapshot did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.snapshot_identifier == null
    error_message = "Cluster snapshot identifier did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.backup_retention_period == 7
    error_message = "Cluster backup retention period did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.enabled_cloudwatch_logs_exports == toset(["audit", "error", "general", "slowquery", "postgresql"])
    error_message = "Cluster enabled cloudwatch log exports did not match expected value"
  }

  assert {
    condition     = length(aws_rds_cluster.cluster.serverlessv2_scaling_configuration) == 0
    error_message = "Cluster serverlessv2 scaling count did not match expected value"
  }

  assert {
    condition     = length(aws_rds_cluster_instance.instances) == 1
    error_message = "Number of cluster instances did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster_instance.instances[0].identifier == "postgres-instance-0"
    error_message = "Cluster instance name did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster_instance.instances[0].instance_class == "db.t3.medium"
    error_message = "Cluster instance class did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster_instance.instances[0].engine == "aurora-postgresql"
    error_message = "Cluster instance engine did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster_instance.instances[0].engine_version == "15.2"
    error_message = "Cluster instance engine version did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster_instance.instances[0].db_subnet_group_name == aws_db_subnet_group.rds.name
    error_message = "Cluster instance subnet group name did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster_instance.instances[0].performance_insights_enabled == true
    error_message = "Cluster instance performance insights enabled did not match expected value"
  }

  assert {
    condition     = aws_db_proxy.proxy.engine_family == "POSTGRESQL"
    error_message = "DB proxy engine family did not match expected value"
  }

  assert {
    condition     = aws_db_proxy.proxy.vpc_subnet_ids == toset(["subnet1234"])
    error_message = "DB proxy subnet IDs did not match expected value"
  }

  assert {
    condition     = aws_db_subnet_group.rds.subnet_ids == toset(["subnet1234"])
    error_message = "DB subnet group subnet IDs did not match expected value"
  }

  assert {
    condition     = length(aws_db_event_subscription.rds_sg_events_alerts) == 0
    error_message = "DB event subscription resource count did not match expected value"
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.log_exports) == 5
    error_message = "CloudWatch log exports log group count did not match expected value"
  }

  assert {
    condition     = aws_cloudwatch_log_group.log_exports["audit"].name == "/aws/rds/cluster/postgres-cluster/audit"
    error_message = "CloudWatch log exports audit log group name did not match expected value"
  }

  assert {
    condition     = aws_cloudwatch_log_group.log_exports["error"].name == "/aws/rds/cluster/postgres-cluster/error"
    error_message = "CloudWatch log exports error log group name did not match expected value"
  }

  assert {
    condition     = aws_cloudwatch_log_group.log_exports["general"].name == "/aws/rds/cluster/postgres-cluster/general"
    error_message = "CloudWatch log exports general log group name did not match expected value"
  }

  assert {
    condition     = aws_cloudwatch_log_group.log_exports["slowquery"].name == "/aws/rds/cluster/postgres-cluster/slowquery"
    error_message = "CloudWatch log exports error log group name did not match expected value"
  }

  assert {
    condition     = aws_cloudwatch_log_group.log_exports["postgresql"].name == "/aws/rds/cluster/postgres-cluster/postgresql"
    error_message = "CloudWatch log exports error log group name did not match expected value"
  }

  assert {
    condition     = local.database_port == 5432
    error_message = "Local database port did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.iam_database_authentication_enabled == false
    error_message = "IAM database authentication enabled did not match expected value"
  }
}
