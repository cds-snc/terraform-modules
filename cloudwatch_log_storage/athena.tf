#
# Optionally create Athena queries to create a partitioned table and saved queries that can be used to query the log data
#
resource "aws_athena_named_query" "cloudwatch_create_table" {
  count = local.is_athena_enabled ? 1 : 0

  name      = "CloudWatch Log Storage: create table"
  workgroup = var.athena_workgroup_name
  database  = var.athena_database_name
  query = templatefile("${path.module}/sql/cloudwatch_create_table.sql",
    {
      bucket_name   = module.cloudwatch_log_storage.s3_bucket_id
      database_name = var.athena_database_name
      table_name    = "${var.product_name}_cloudwatch_log_storage"
    }
  )
}

resource "aws_athena_named_query" "cloudwatch_view_logs" {
  count = local.is_athena_enabled ? 1 : 0

  name      = "CloudWatch Log Storage: view logs"
  workgroup = var.athena_workgroup_name
  database  = var.athena_database_name
  query = templatefile("${path.module}/sql/cloudwatch_view_logs.sql",
    {
      database_name = var.athena_database_name
      table_name    = "${var.product_name}_cloudwatch_log_storage"
    }
  )
}
