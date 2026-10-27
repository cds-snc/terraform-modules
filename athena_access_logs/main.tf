/* 
* # athena_access_logs
* Creates an Athena database, work group and saved queries for examining WAF ACL and Load Balancer access logs.
*
* When `athena_managed_query_results_enabled` is `true`, the workgroup stores query results in Athena managed storage instead of S3.
*/

resource "aws_athena_database" "logs" {
  name          = var.athena_database_name
  bucket        = var.athena_bucket_name
  force_destroy = true

  encryption_configuration {
    encryption_option = "SSE_S3"
  }
}

resource "aws_athena_workgroup" "logs" {
  name          = var.athena_workgroup_name
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    dynamic "result_configuration" {
      for_each = var.athena_managed_query_results_enabled ? [] : [1]

      content {
        output_location = "s3://${var.athena_bucket_name}/logs/"

        encryption_configuration {
          encryption_option = "SSE_S3"
        }
      }
    }

    dynamic "managed_query_results_configuration" {
      # checkov:skip=CKV_AWS_159:AWS service key encryption is sufficient
      for_each = var.athena_managed_query_results_enabled ? [1] : []

      content {
        enabled = true
      }
    }
  }

  tags = local.common_tags
}

resource "aws_athena_named_query" "lb_create_table" {
  count = var.lb_access_queries_create ? 1 : 0

  name      = "LB: create table"
  workgroup = aws_athena_workgroup.logs.name
  database  = aws_athena_database.logs.name
  query = templatefile("${path.module}/sql/lb_create_table.sql",
    {
      bucket_location = "s3://${var.lb_access_log_bucket_name}/lb_logs/AWSLogs/${local.account_id}/elasticloadbalancing/${local.region}/"
      database_name   = aws_athena_database.logs.name
      table_name      = "lb_logs"
    }
  )
}

resource "aws_athena_named_query" "waf_create_table" {
  count = var.waf_access_queries_create ? 1 : 0

  name      = "WAF: create table"
  workgroup = aws_athena_workgroup.logs.name
  database  = aws_athena_database.logs.name
  query = templatefile("${path.module}/sql/waf_create_table.sql",
    {
      bucket_location = "s3://${var.waf_access_log_bucket_name}/waf_acl_logs/AWSLogs/${local.account_id}/"
      database_name   = aws_athena_database.logs.name
      table_name      = "waf_logs"
    }
  )
}

resource "aws_athena_named_query" "waf_blocked_requests" {
  count = var.waf_access_queries_create ? 1 : 0

  name      = "WAF: blocked requests"
  workgroup = aws_athena_workgroup.logs.name
  database  = aws_athena_database.logs.name
  query = templatefile("${path.module}/sql/waf_blocked_requests.sql",
    {
      database_name = aws_athena_database.logs.name
      table_name    = "waf_logs"
    }
  )
}

resource "aws_athena_named_query" "waf_all_requests" {
  count = var.waf_access_queries_create ? 1 : 0

  name      = "WAF: all requests"
  workgroup = aws_athena_workgroup.logs.name
  database  = aws_athena_database.logs.name
  query = templatefile("${path.module}/sql/waf_all_requests.sql",
    {
      database_name = aws_athena_database.logs.name
      table_name    = "waf_logs"
    }
  )
}
