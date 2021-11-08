/* # lambda
* 
* This module creates a lambda function and a role. It also has toggles for the various ways lambdas are invoked at CDS.
*
*/
resource "aws_lambda_function" "this" {
  function_name = var.name

  package_type = "Image"
  image_uri    = var.image_uri

  role    = aws_iam_role.api.arn
  timeout = var.timeout

  memory_size = var.memory

  environment {
    variables = locals.common_tags
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
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = "14"
  tags              = this.local_tags
}
