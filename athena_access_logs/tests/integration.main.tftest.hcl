provider "aws" {
  region = "ca-central-1"
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "lb_table_create" {
  variables {
    athena_bucket_name        = run.setup.athena_bucket_name
    lb_access_queries_create  = true
    lb_access_log_bucket_name = run.setup.access_logs_bucket_name
  }

  assert {
    condition     = aws_athena_database.logs.bucket == run.setup.athena_bucket_name
    error_message = "Athena DB bucket did not match expected value"
  }

  assert {
    condition     = length(aws_athena_named_query.lb_create_table) == 1
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

  assert {
    condition     = strcontains(aws_athena_named_query.lb_create_table[0].query, "s3://${run.setup.access_logs_bucket_name}/lb_logs/AWSLogs/${local.account_id}/elasticloadbalancing/${local.region}/")
    error_message = "Athena name query LB create table query did not contain expected value"
  }
}
