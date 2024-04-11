#
# Activity stream decrypt function
# The events are encrypted by the activity stream, so we need to decrypt them before we store them
# to allow for easier monitoring.
#

#
# An external data provider is used to download and package the Python dependencies.
# This is done so that the Lambda layer is only updated when the `requirements.txt`
# file changes.
#
data "external" "decrypt_deps" {
  program = ["bash", "${path.module}/scripts/decrypt_deps.sh"]
  query = {
    python_version = local.python_version
    src_dir        = abspath(path.module)
  }
}

resource "aws_lambda_layer_version" "decrypt_deps" {
  layer_name          = "decrypt-deps"
  filename            = data.external.decrypt_deps.result.layer_zip
  source_code_hash    = filebase64sha256(data.external.decrypt_deps.result.layer_zip)
  compatible_runtimes = [local.python_version]
}

data "archive_file" "decrypt_code" {
  type        = "zip"
  source_file = "${path.module}/lambda/decrypt.py"
  output_path = "/tmp/decrypt.zip"
}

resource "aws_lambda_function" "decrypt" {
  function_name = local.decrypt_lambda_function
  handler       = "decrypt.handler"
  runtime       = local.python_version
  memory_size   = var.decrypt_lambda_memory_size
  timeout       = var.decrypt_lambda_timeout
  role          = aws_iam_role.decrypt.arn

  filename         = data.archive_file.decrypt_code.output_path
  source_code_hash = data.archive_file.decrypt_code.output_base64sha256
  layers           = [aws_lambda_layer_version.decrypt_deps.arn]

  environment {
    variables = {
      RDS_ACTIVITY_STREAM_NAME = aws_rds_cluster_activity_stream.activity_stream.kinesis_stream_name
    }
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "decrypt" {
  name              = "/aws/lambda/${local.decrypt_lambda_function}"
  retention_in_days = "14"
  tags              = local.common_tags
}

#
# IAM
#
resource "aws_iam_role" "decrypt" {
  name               = local.decrypt_lambda_function
  assume_role_policy = data.aws_iam_policy_document.decrypt_assume.json
  tags               = local.common_tags
}

resource "aws_iam_policy" "decrypt" {
  name   = local.decrypt_lambda_function
  path   = "/"
  policy = data.aws_iam_policy_document.decrypt.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "decrypt" {
  role       = aws_iam_role.decrypt.name
  policy_arn = aws_iam_policy.decrypt.arn
}

data "aws_iam_policy_document" "decrypt_assume" {
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

data "aws_iam_policy_document" "decrypt" {
  statement {
    sid    = "CloudWatchWriteLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.decrypt.arn}:log-stream:*"
    ]
  }

  statement {
    sid    = "KinesisListStreams"
    effect = "Allow"
    actions = [
      "kinesis:ListStreams"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "KinesisReadDBActivityStream"
    effect = "Allow"
    actions = [
      "kinesis:GetRecords",
      "kinesis:GetShardIterator",
      "kinesis:DescribeStream",
      "kinesis:DescribeStreamSummary",
      "kinesis:ListShards",
      "kinesis:ListStreams"
    ]
    resources = [
      local.database_kinesis_stream_arn
    ]
  }

  statement {
    sid    = "KMSDecryptDatabaseActivityStream"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      aws_kms_key.activity_stream.arn
    ]
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.decrypt.function_name
  principal     = "firehose.amazonaws.com"
  source_arn    = aws_kinesis_firehose_delivery_stream.activity_stream.arn
}
