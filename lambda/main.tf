/* # lambda
* 
* This module creates a lambda function and a role. It also has toggles for the various ways lambdas are invoked at CDS.
*
*/
resource "aws_lambda_function" "this" {
  function_name                  = var.name
  package_type                   = "Image"
  image_uri                      = var.image_uri
  architectures                  = var.architectures
  role                           = aws_iam_role.this.arn
  timeout                        = var.timeout
  memory_size                    = var.memory
  reserved_concurrent_executions = var.reserved_concurrent_executions

  dynamic "environment" {
    for_each = length(keys(var.environment_variables)) == 0 ? [] : [true]
    content {
      variables = var.environment_variables
    }
  }

  tracing_config {
    mode = "PassThrough"
  }

  vpc_config {
    security_group_ids = var.vpc.security_group_ids
    subnet_ids         = var.vpc.subnet_ids
  }

  # We don't deploy through terraform, we just set the image_uri once
  lifecycle {
    ignore_changes = [
      image_uri,
    ]
  }

  dynamic "dead_letter_config" {
    for_each = length(var.dead_letter_queue_arn) == 0 ? [] : [true]
    content {
      target_arn = var.dead_letter_queue_arn
    }
  }

  ephemeral_storage {
    size = var.ephemeral_storage
  }

  dynamic "file_system_config" {
    for_each = length(keys(var.file_system_config)) == 0 ? [] : [var.file_system_config]

    content {
      arn              = file_system_config.value.arn
      local_mount_path = file_system_config.value.local_mount_path
    }
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "this" {
  #checkov:skip=CKV_AWS_158:We trust the AWS provided keys
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.log_group_retention_period
  tags              = local.common_tags
}

resource "aws_cloudwatch_query_definition" "lambda_statistics" {
  name = "Lambda Statistics - ${var.name}"

  log_group_names = [
    "aws_cloudwatch_log_group.this"
  ]

  query_string = <<-QUERY
    filter @type = “REPORT”
    | stats
    count(@type) as countInvocations,
    count(@initDuration) as countColdStarts, (count(@initDuration)/count(@type))*100 as percentageColdStarts,
    max(@initDuration) as maxColdStartTime,
    avg(@duration) as averageDuration,
    max(@duration) as maxDuration,
    min(@duration) as minDuration,
    avg(@maxMemoryUsed) as averageMemoryUsed,
    max(@memorySize) as memoryAllocated, (avg(@maxMemoryUsed)/max(@memorySize))*100 as percentageMemoryUsed
    by bin(1h) as timeFrame
  QUERY
}

resource "aws_lambda_alias" "this" {
  count            = var.alias_name != "" ? 1 : 0
  name             = var.alias_name
  description      = "The most recently deployed version of the API"
  function_name    = aws_lambda_function.this.function_name
  function_version = aws_lambda_function.this.version
}