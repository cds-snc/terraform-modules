provider "aws" {
  region = "ca-central-1"
}

variables {
  name = "postgres-iam"

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

  proxy_iam_authentication_enabled = true
  proxy_iam_authentication_task_role_arns = {
    app = ["arn:aws:iam::123456789012:role/test-app-task"]
  }
}

run "postgres_iam_proxy" {
  command = plan

  assert {
    condition     = aws_rds_cluster.cluster.iam_database_authentication_enabled == true
    error_message = "IAM database authentication should be enabled for the cluster"
  }

  assert {
    condition     = aws_db_proxy.proxy[0].default_auth_scheme == "IAM_AUTH"
    error_message = "The proxy should require IAM authentication"
  }

  assert {
    condition     = length(aws_db_proxy.proxy[0].auth) == 0
    error_message = "The IAM-authenticated proxy should not configure Secrets Manager authentication"
  }

  assert {
    condition     = length(aws_db_proxy_endpoint.reader) == 1 && aws_db_proxy_endpoint.reader[0].target_role == "READ_ONLY"
    error_message = "The proxy should create a read-only endpoint when enabled"
  }

  assert {
    condition     = length(aws_secretsmanager_secret.connection_string) == 0 && length(aws_secretsmanager_secret.proxy_connection_string) == 0
    error_message = "The IAM-authenticated proxy should not create password-bearing connection secrets"
  }

  assert {
    condition     = length(aws_iam_policy.task_iam_database_connect) == 1 && aws_iam_role_policy_attachment.task_iam_database_connect["app:arn:aws:iam::123456789012:role/test-app-task"].role == "test-app-task"
    error_message = "The application task role should receive the proxy IAM database policy"
  }

}