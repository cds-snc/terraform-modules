provider "aws" {
  region = "ca-central-1"
}

  variables {
    name = "mysql"

    database_name  = "terratest_mysql"
    engine         = "aurora-mysql"
    engine_version = "5.7.mysql_aurora.2.11.2"
    instances      = 2
    instance_class = "db.t3.small"
    username       = "thebigcheese"
    password       = "pasword123"

    serverless_min_capacity = 1
    serverless_max_capacity = 2

    backup_retention_period = 1
    preferred_backup_window = "01:00-03:00"
    snapshot_identifier     = "snapshot-identifier"

    security_group_ids              = ["sg1234"]
    enabled_cloudwatch_logs_exports = ["audit"]

    vpc_id     = "vpc1234"
    subnet_ids = ["subnet1234", "subnet5678"]

    security_group_notifications_topic_arn = "arn:aws:sns:us-east-1:123456789012:security-group-notifications"
  }

run "mysql_cluster" {
  command = plan

  assert {
    condition     = aws_rds_cluster.cluster.cluster_identifier == "mysql-cluster"
    error_message = "Cluster identifier did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.engine == "aurora-mysql"
    error_message = "Cluster engine did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.engine_version == "5.7.mysql_aurora.2.11.2"
    error_message = "Cluster engine version did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.master_username == "thebigcheese"
    error_message = "Cluster username did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.master_password == "pasword123"
    error_message = "Cluster password did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.backtrack_window == 259200
    error_message = "Cluster backtrack window did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.snapshot_identifier == "snapshot-identifier"
    error_message = "Cluster snapshot identifier did not match expected value"
  }  

  assert {
    condition     = aws_rds_cluster.cluster.enabled_cloudwatch_logs_exports == toset(["audit"])
    error_message = "Cluster enabled cloudwatch log exports did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.serverlessv2_scaling_configuration[0].min_capacity == 1
    error_message = "Cluster serverlessv2 scaling configuration min capacity did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster.cluster.serverlessv2_scaling_configuration[0].max_capacity == 2
    error_message = "Cluster serverlessv2 scaling configuration max capacity did not match expected value"
  }

  assert {
    condition     = length(aws_rds_cluster_instance.instances) == 2
    error_message = "Number of cluster instances did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster_instance.instances[0].identifier == "mysql-instance-0"
    error_message = "Cluster instance name did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster_instance.instances[0].instance_class == "db.t3.small"
    error_message = "Cluster instance class did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster_instance.instances[0].engine == "aurora-mysql"
    error_message = "Cluster instance engine did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster_instance.instances[0].engine_version == "5.7.mysql_aurora.2.11.2"
    error_message = "Cluster instance engine version did not match expected value"
  }

  assert {
    condition     = aws_rds_cluster_instance.instances[0].db_subnet_group_name == aws_db_subnet_group.rds.name
    error_message = "Cluster instance subnet group name did not match expected value"
  }

  assert {
    condition     = aws_db_proxy.proxy.engine_family == "MYSQL"
    error_message = "DB proxy engine family did not match expected value"
  }

  assert {
    condition     = aws_db_proxy.proxy.vpc_subnet_ids == toset(["subnet1234", "subnet5678"])
    error_message = "DB proxy subnet IDs did not match expected value"
  }

  assert {
    condition     = aws_db_subnet_group.rds.subnet_ids == toset(["subnet1234", "subnet5678"])
    error_message = "DB subnet group subnet IDs did not match expected value"
  }

  assert {
    condition     = aws_db_event_subscription.rds_sg_events_alerts[0].sns_topic == "arn:aws:sns:us-east-1:123456789012:security-group-notifications"
    error_message = "DB event subscription SNS topic ARN did not match expected value"
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.log_exports) == 1
    error_message = "CloudWatch log exports log group count did not match expected value"
  }

  assert {
    condition     = aws_cloudwatch_log_group.log_exports["audit"].name == "/aws/rds/cluster/mysql-cluster/audit"
    error_message = "CloudWatch log exports audit log group name did not match expected value"
  }
}

