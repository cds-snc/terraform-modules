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

  vpc_id     = "vpc1234"
  subnet_ids = ["subnet1234"]
  use_proxy  = false
}

run "postgres_cluster" {
  command = plan

  assert {
    condition     = length(aws_db_proxy.proxy) == 0
    error_message = "Proxy resource should not exist"
  }

  assert {
    condition     = length(aws_iam_role.rds_proxy) == 0
    error_message = "Proxy resource should not exist"
  }

  assert {
    condition     = length(aws_iam_policy.read_connection_string) == 0
    error_message = "Proxy resource should not exist"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.read_connection_string) == 0
    error_message = "Proxy resource should not exist"
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.proxy) == 0
    error_message = "Proxy resource should not exist"
  }

  assert {
    condition     = length(aws_db_proxy_default_target_group.this) == 0
    error_message = "aws_db_proxy_default_target_group.this resource should not exist"
  }

  assert {
    condition     = length(aws_db_proxy_target.target) == 0
    error_message = "aws_db_proxy_target.target resource should not exist"
  }

  assert {
    condition     = length(aws_secretsmanager_secret.connection_string) == 0
    error_message = "aws_secretsmanager_secret.connection_string resource should not exist"
  }

  assert {
    condition     = length(aws_secretsmanager_secret_version.connection_string) == 0
    error_message = "aws_secretsmanager_secret_version.connection_string resource should not exist"
  }

  assert {
    condition     = length(aws_secretsmanager_secret.proxy_connection_string) == 0
    error_message = "aws_secretsmanager_secret.proxy_connection_string resource should not exist"
  }

  assert {
    condition     = length(aws_secretsmanager_secret_version.proxy_connection_string) == 0
    error_message = "aws_secretsmanager_secret_version.proxy_connection_string resource should not exist"
  }

  assert {
    condition     = aws_security_group.rds.name == "postgres_rds_sg"
    error_message = "RDS security group name did not match expected value"
  }
}