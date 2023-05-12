/* 
* Automatically notify when a new iam user is added to an aws account 
*
* This module sets up a lambda that will automatically notify of any iam user added in an AWS account.
*/

# Get the current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#
# S3 Bucket: Create an S3 bucket for cloudtrail
#
resource "aws_s3_bucket" "new_iam_user_bucket" {
  bucket = "new-iam-user-bucket1234567"
  force_destroy = true

  tags = {
    Name        = "new-iam-user-bucket"
  }
}

data "aws_iam_policy_document" "new_iam_user_detection" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.new_iam_user_bucket.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.new_iam_user_bucket.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}
resource "aws_s3_bucket_policy" "new_iam_user_detection_policy" {
  bucket = aws_s3_bucket.new_iam_user_bucket.id
  policy = data.aws_iam_policy_document.new_iam_user_detection.json
}

#
# Cloudtrail: Send CreateUser events to Lambda
#
resource "aws_cloudtrail" "new_iam_user_detection" {
  name                       = "new-iam-user-cloudtrail"
  s3_bucket_name             = aws_s3_bucket.new_iam_user_bucket.id
  include_global_service_events = true
}

resource "aws_cloudwatch_event_rule" "new_iam_user_detection_event_rule" {
  name        = "new-iam-user-detection-event-rule"
  description = "Send CloudTrail events to Lambda"

  event_pattern = <<PATTERN
{
  "source": ["aws.cloudtrail"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["CreateUser"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "new_iam_user_detection_event_target" {
  rule      = aws_cloudwatch_event_rule.new_iam_user_detection_event_rule.name
  target_id = "notify_new_iam_user_added"
  arn       = aws_lambda_function.new_iam_user_added.arn
}

#
# Lambda: Notify when a new iam user is created 
#
data "archive_file" "notify_new_iam_user_added" {
  type        = "zip"
  source_file = "${path.module}/functions/index.py"
  output_path = "/tmp/notify_new_iam_user_added.zip"
}

# Lambda function that is used to detect a new iam user added 
resource "aws_lambda_function" "new_iam_user_added" {
  function_name = var.function_name
  description   = "Repsonds to new iam user added"
  role          = aws_iam_role.new_iam_user_response_role.arn
  environment {
    variables = {
      outbound_topic_arn = "arn:aws:sns:ca-central-1:${local.account_id}:internal-sre-alert" 
      logging_level = var.logging_level
    }
  }
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60

  filename         = data.archive_file.notify_new_iam_user_added.output_path
  source_code_hash = filebase64sha256(data.archive_file.notify_new_iam_user_added.output_path)

  tracing_config {
    mode = "PassThrough"
  }
  depends_on = [
    aws_iam_role.new_iam_user_response_role
  ]
}

# Permission to execute the Lambda function
resource "aws_lambda_permission" "new_iam_user_added_lambda_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.new_iam_user_added.arn
  principal = "events.amazonaws.com"
}
