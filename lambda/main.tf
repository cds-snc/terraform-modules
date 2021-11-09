/* # lambda
* 
* This module creates a lambda function and a role. It also has toggles for the various ways lambdas are invoked at CDS.
*
*/
resource "aws_lambda_function" "this" {
  function_name                  = var.name
  package_type                   = "Image"
  image_uri                      = var.image_uri
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

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "this" {
  #checkov:skip=CKV_AWS_158:We trust the AWS provided keys
  name              = "/aws/lambda/${var.name}"
  retention_in_days = "14"
  tags              = local.common_tags
}
