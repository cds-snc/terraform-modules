/* 
* # S3_scan_object
* Lambda function that triggers a [ClamAV scan](https://scan-files.alpha.canada.ca) of newly created S3 objects and updates the object with the scan results.
* 
* The function is invoked by `s3:ObjectCreated:*` events.
*
* ## ⚠️ Notes
* - To use the default values for the following variables, your account must be part of our AWS organization:
*    - `scan_files_role_arn`
*    - `s3_scan_object_function_arn`
*    - `s3_scan_object_role_arn`
* - You can build your own Lambda Docker image using the code in [cds-snc/scan-files/module/s3-scan-object](https://github.com/cds-snc/scan-files/tree/main/module/s3-scan-object).
*/
resource "aws_lambda_function" "s3_scan_object" {
  function_name = "s3-scan-object-${var.product_name}"
  role          = aws_iam_role.s3_scan_object.arn
  runtime       = "python3.8"
  handler       = "main.handler"
  memory_size   = 512

  filename         = data.archive_file.s3_scan_object.output_path
  source_code_hash = filebase64sha256(data.archive_file.s3_scan_object.output_path)

  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = {
      ACCOUNT_ID                  = local.account_id
      S3_SCAN_OBJECT_FUNCTION_ARN = var.s3_scan_object_function_arn
    }
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = local.common_tags
}

data "archive_file" "s3_scan_object" {
  type        = "zip"
  source_file = "${path.module}/lambda/main.py"
  output_path = "/tmp/main.py.zip"
}

resource "aws_cloudwatch_log_group" "s3_scan_object" {
  name              = "/aws/lambda/${aws_lambda_function.s3_scan_object.function_name}"
  retention_in_days = 7
  tags              = local.common_tags
}

resource "aws_iam_role" "s3_scan_object" {
  name               = "S3ScanObject-${var.product_name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_policy" "s3_scan_object" {
  name   = "S3ScanObject-${var.product_name}"
  path   = "/"
  policy = data.aws_iam_policy_document.s3_scan_object.json
}

resource "aws_iam_role_policy_attachment" "s3_scan_object" {
  role       = aws_iam_role.s3_scan_object.name
  policy_arn = aws_iam_policy.s3_scan_object.arn
}

data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_scan_object" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.s3_scan_object.arn,
      "${aws_cloudwatch_log_group.s3_scan_object.arn}:log-stream:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      var.s3_scan_object_function_arn
    ]
  }
}
