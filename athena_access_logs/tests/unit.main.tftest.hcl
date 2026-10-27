provider "aws" {
  region = "ca-central-1"
}

run "default_inputs" {
  command = plan

  variables {
    athena_bucket_name = "athena-logs"
  }

  assert {
    condition     = aws_athena_database.logs.name == "access_logs"
    error_message = "Athena DB name did not match expected value"
  }

  assert {
    condition     = aws_athena_database.logs.bucket == "athena-logs"
    error_message = "Athena DB bucket did not match expected value"
  }

  assert {
    condition     = aws_athena_database.logs.encryption_configuration[0].encryption_option == "SSE_S3"
    error_message = "Athena DB encryption option did not match expected value"
  }

  assert {
    condition     = aws_athena_workgroup.logs.name == "logs"
    error_message = "Athena workgroup name did not match expected value"
  }

  assert {
    condition     = aws_athena_workgroup.logs.configuration[0].result_configuration[0].output_location == "s3://${var.athena_bucket_name}/logs/"
    error_message = "Athena workgroup output location did not match expected value"
  }

  assert {
    condition     = aws_athena_workgroup.logs.configuration[0].result_configuration[0].encryption_configuration[0].encryption_option == "SSE_S3"
    error_message = "Athena workgroup result encryption option did not match expected value"
  }

  assert {
    condition     = length(aws_athena_workgroup.logs.configuration[0].managed_query_results_configuration) == 0
    error_message = "Athena managed query results configuration should be omitted by default"
  }

  assert {
    condition     = length(aws_athena_named_query.lb_create_table) == 0
    error_message = "Athena name query LB create table count did not match expected value"
  }

  assert {
    condition     = length(aws_athena_named_query.waf_create_table) == 0
    error_message = "Athena name query WAF create table count did not match expected value"
  }

  assert {
    condition     = length(aws_athena_named_query.waf_all_requests) == 0
    error_message = "Athena name queryWAF all requests count did not match expected value"
  }

  assert {
    condition     = length(aws_athena_named_query.waf_blocked_requests) == 0
    error_message = "Athena name query WAF blocked requests count did not match expected value"
  }
}

run "managed_query_results_enabled" {
  command = plan

  variables {
    athena_managed_query_results_enabled = true
  }

  assert {
    condition     = aws_athena_workgroup.logs.configuration[0].managed_query_results_configuration[0].enabled == true
    error_message = "Athena managed query results should be enabled"
  }

  assert {
    condition     = length(aws_athena_workgroup.logs.configuration[0].result_configuration) == 0
    error_message = "Athena S3 result configuration should be omitted when managed query results are enabled"
  }
}

run "custom_inputs" {
  command = plan

  variables {
    athena_bucket_name    = "athena-logs"
    athena_database_name  = "mmm_databasey"
    athena_workgroup_name = "its_big_its_heavy_its_wood"

    lb_access_queries_create   = true
    lb_access_log_bucket_name  = "lb-logs"
    waf_access_queries_create  = true
    waf_access_log_bucket_name = "waf-logs"
  }

  assert {
    condition     = aws_athena_database.logs.name == "mmm_databasey"
    error_message = "Athena DB name did not match expected value"
  }

  assert {
    condition     = aws_athena_workgroup.logs.name == "its_big_its_heavy_its_wood"
    error_message = "Athena workgroup name did not match expected value"
  }

  assert {
    condition     = length(aws_athena_named_query.lb_create_table) == 1
    error_message = "Athena name query LB create table count did not match expected value"
  }

  assert {
    condition     = length(aws_athena_named_query.waf_create_table) == 1
    error_message = "Athena name query WAF create table count did not match expected value"
  }

  assert {
    condition     = length(aws_athena_named_query.waf_all_requests) == 1
    error_message = "Athena name queryWAF all requests count did not match expected value"
  }

  assert {
    condition     = length(aws_athena_named_query.waf_blocked_requests) == 1
    error_message = "Athena name query WAF blocked requests count did not match expected value"
  }

  assert {
    condition     = aws_athena_named_query.lb_create_table[0].name == "LB: create table"
    error_message = "Athena name query LB create table name did not match expected value"
  }

  assert {
    condition     = aws_athena_named_query.waf_create_table[0].name == "WAF: create table"
    error_message = "Athena name query WAF create table name did not match expected value"
  }

  assert {
    condition     = strcontains(aws_athena_named_query.lb_create_table[0].query, "s3://lb-logs/lb_logs/AWSLogs/${local.account_id}/elasticloadbalancing/${local.region}/")
    error_message = "Athena name query LB create table query did not contain expected value"
  }

  assert {
    condition     = strcontains(aws_athena_named_query.waf_create_table[0].query, "s3://waf-logs/waf_acl_logs/AWSLogs/${local.account_id}/")
    error_message = "Athena name query WAF create table query did not contain expected value"
  }
}
