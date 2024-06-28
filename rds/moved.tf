#
# Migrations related to the module's ability to create an 
# RDS cluster without an RDS proxy.  This will move the previously
# unindexed resources in the TF state for projects using older
# versions of the module.
#
moved {
  from = aws_db_proxy.proxy
  to   = aws_db_proxy.proxy[0]
}

moved {
  from = aws_db_proxy_target.target
  to   = aws_db_proxy_target.target[0]
}

moved {
  from = aws_db_proxy_default_target_group.this
  to   = aws_db_proxy_default_target_group.this[0]
}

moved {
  from = aws_iam_role.rds_proxy
  to   = aws_iam_role.rds_proxy[0]
}

moved {
  from = aws_iam_policy.read_connection_string
  to   = aws_iam_policy.read_connection_string[0]
}

moved {
  from = aws_iam_role_policy_attachment.read_connection_string
  to   = aws_iam_role_policy_attachment.read_connection_string[0]
}

moved {
  from = aws_secretsmanager_secret.proxy_connection_string
  to   = aws_secretsmanager_secret.proxy_connection_string[0]
}

moved {
  from = aws_secretsmanager_secret_version.proxy_connection_string
  to   = aws_secretsmanager_secret_version.proxy_connection_string[0]
}

moved {
  from = aws_secretsmanager_secret.connection_string
  to   = aws_secretsmanager_secret.connection_string[0]
}

moved {
  from = aws_secretsmanager_secret_version.connection_string
  to   = aws_secretsmanager_secret_version.connection_string[0]
}

moved {
  from = aws_cloudwatch_log_group.proxy
  to   = aws_cloudwatch_log_group.proxy[0]
}

moved {
  from = aws_security_group.rds_proxy
  to   = aws_security_group.rds
}

moved {
  from = aws_security_group_rule.rds_proxy_ingress
  to   = aws_security_group_rule.rds_ingress
}

moved {
  from = aws_security_group_rule.rds_proxy_egress
  to   = aws_security_group_rule.rds_egress
}
