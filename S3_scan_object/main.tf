/* 
* # S3_scan_object
* Trigger [ClamAV scans](https://scan-files.alpha.canada.ca) of newly created S3 objects and updates the object with the scan results.  The S3 events are sent to an SQS queue where they are processed by the Scan Files API.
*
* ## ⚠️ Notes
* - To use the default values for the following variables, your account must be part of our AWS organization:
*    - `scan_files_role_arn`
*    - `s3_scan_object_role_arn`
* - You can build your own Lambda Docker image using the code in [cds-snc/scan-files/module/s3-scan-object](https://github.com/cds-snc/scan-files/tree/main/module/s3-scan-object).
*/
resource "aws_sqs_queue" "s3_scan_object" {
  name                       = "s3-scan-object"
  kms_master_key_id          = aws_kms_key.s3_scan_object_queue.arn
  visibility_timeout_seconds = 300
  tags                       = local.common_tags
}

resource "aws_sqs_queue_policy" "s3_scan_object" {
  queue_url = aws_sqs_queue.s3_scan_object.id
  policy    = data.aws_iam_policy_document.s3_scan_object.json
}

data "aws_iam_policy_document" "s3_scan_object" {
  statement {
    sid    = "S3sendToSQS"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.s3_scan_object.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = local.upload_buckets[*].arn
    }
  }

  statement {
    sid    = "LambdaTriggerFromSQS"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.s3_scan_object_role_arn]
    }
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = [aws_sqs_queue.s3_scan_object.arn]
  }
}
