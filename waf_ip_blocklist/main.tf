/* 
* # WAF IP blocklist
* This module creates a WAF IP blocklist that is automatically updated on a user-defined schedule. 
* 
* The automatic update is based on a service's WAF and load balancer logs where an IP address exceeds the block threshold in a 24 hour period.
*
* The IP block is temporary and the IP address will be removed once it has been at least 24 hours since it has exceeded
* the block threshold.
*/

#
# IPv4 blocklist
#
resource "aws_wafv2_ip_set" "ipv4_blocklist" {
  name               = local.blocklist_name
  scope              = var.waf_scope
  ip_address_version = "IPV4"
  addresses          = []

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      addresses
    ]
  }
}

#
# Lambda that updates the blocklist
#
resource "aws_lambda_function" "ipv4_blocklist" {
  function_name = local.blocklist_name
  description   = "Update the IPv4 blocklist based on the WAF logs"

  filename    = data.archive_file.ipv4_blocklist.output_path
  handler     = "blocklist.handler"
  runtime     = "python3.11"
  timeout     = 300
  memory_size = 1024

  role             = aws_iam_role.ipv4_blocklist.arn
  source_code_hash = filebase64sha256(data.archive_file.ipv4_blocklist.output_path)

  environment {
    variables = {
      ATHENA_OUTPUT_BUCKET = var.athena_query_results_bucket
      ATHENA_DATABASE      = var.athena_database_name
      ATHENA_LB_TABLE      = var.athena_lb_table_name
      ATHENA_WAF_TABLE     = var.athena_waf_table_name
      ATHENA_WORKGROUP     = var.athena_workgroup_name
      BLOCK_THRESHOLD      = var.waf_block_threshold
      QUERY_LB             = var.query_lb
      QUERY_WAF            = var.query_waf
      WAF_IP_SET_ID        = aws_wafv2_ip_set.ipv4_blocklist.id
      WAF_IP_SET_NAME      = aws_wafv2_ip_set.ipv4_blocklist.name
      WAF_RULE_IDS_SKIP    = join(",", var.waf_rule_ids_skip)
      WAF_SCOPE            = var.waf_scope
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = local.common_tags
}

data "archive_file" "ipv4_blocklist" {
  type = "zip"

  source {
    content  = file("${path.module}/lambda/blocklist.py")
    filename = "blocklist.py"
  }

  source {
    content  = file("${path.module}/lambda/query_lb.sql")
    filename = "query_lb.sql"
  }

  source {
    content  = file("${path.module}/lambda/query_waf.sql")
    filename = "query_waf.sql"
  }

  output_path = "/tmp/blocklist.zip"
}

resource "aws_cloudwatch_log_group" "ipv4_blocklist" {
  name              = "/aws/lambda/${local.blocklist_name}"
  retention_in_days = "14"
  tags              = local.common_tags
}

#
# Schedule and permissions for updating the blocklist
#
resource "aws_cloudwatch_event_target" "ipv4_blocklist" {
  arn  = aws_lambda_function.ipv4_blocklist.arn
  rule = aws_cloudwatch_event_rule.ipv4_blocklist.id
}

resource "aws_cloudwatch_event_rule" "ipv4_blocklist" {
  name                = local.blocklist_name
  description         = "Update the IPv4 blocklist"
  schedule_expression = var.waf_ip_blocklist_update_schedule
  tags                = local.common_tags
}

resource "aws_lambda_permission" "ipv4_blocklist" {
  statement_id  = "AllowExecutionFromCloudWatch-${local.blocklist_name}"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.ipv4_blocklist.function_name
  source_arn    = aws_cloudwatch_event_rule.ipv4_blocklist.arn
}


#
# Metrics for actions that are taken on the blocklist
#

resource "aws_cloudwatch_log_metric_filter" "ip_added_to_block_list" {
  name           = "IpAddedToBlockList"
  pattern        = "\"[Metric] - New IP added to WAF IP Set\""
  log_group_name = aws_cloudwatch_log_group.ipv4_blocklist.name

  metric_transformation {
    name          = "IpAddedToBlockList"
    namespace     = "CDS_Platform"
    value         = "1"
    default_value = "0"
  }
}