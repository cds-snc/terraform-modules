/* 
* # Lambda redirect
* 
* Creates a 301 redirect from a source domain to a target domain using Cloudfront and a Lambda function.
* HTTP requests are automatically redirected to HTTPS by the CloudFront distribution.
*/

#
# Redirector function invoked by CloudFront
#
resource "aws_lambda_function" "redirector" {
  function_name = local.lambda_function_name
  role          = aws_iam_role.redirector.arn
  runtime       = "nodejs16.x"
  handler       = "index.handler"
  memory_size   = 128

  filename         = data.archive_file.redirector_src.output_path
  source_code_hash = data.archive_file.redirector_src.output_base64sha256

  reserved_concurrent_executions = 1

  tracing_config {
    mode = "PassThrough"
  }

  tags = local.common_tags
}

data "archive_file" "redirector_src" {
  type        = "zip"
  output_path = "/tmp/redirector_src.zip"
  source {
    content  = <<-EOF
      exports.handler = async (event) => {
        return {
          statusCode: 301,
          headers: { 
            Location: "https://${var.domain_name_target}"
          }
        };
      };
    EOF
    filename = "index.js"
  }
}

resource "aws_cloudwatch_log_group" "redirector" {
  name              = "/aws/lambda/${aws_lambda_function.redirector.function_name}"
  retention_in_days = 7
  tags              = local.common_tags
}

#
# Function URL used by CloudFront
#
resource "aws_lambda_function_url" "redirector" {
  function_name      = aws_lambda_function.redirector.function_name
  authorization_type = "NONE"
}

#
# Function IAM role
#
resource "aws_iam_role" "redirector" {
  name               = "lambda-redirector"
  assume_role_policy = data.aws_iam_policy_document.service_principal.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "service_principal" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "redirector_cloudwatch" {
  name   = "lambda-redirector-cloudwatch"
  path   = "/"
  policy = data.aws_iam_policy_document.redirector_cloudwatch.json
}

data "aws_iam_policy_document" "redirector_cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.redirector.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "redirector_cloudwatch" {
  role       = aws_iam_role.redirector.name
  policy_arn = aws_iam_policy.redirector_cloudwatch.arn
}
