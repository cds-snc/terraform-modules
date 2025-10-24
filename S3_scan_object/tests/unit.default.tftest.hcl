provider "aws" {
  region = "ca-central-1"
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

# Default resources created by the module
run "default" {
  command = plan

  variables {
    s3_upload_bucket_names = ["test-bucket-1", "test-bucket-2"]
  }

  assert {
    condition = local.upload_buckets == [{
      id        = "test-bucket-1"
      arn       = "arn:aws:s3:::test-bucket-1"
      arn_items = "arn:aws:s3:::test-bucket-1/*"
      },
      {
        id        = "test-bucket-2"
        arn       = "arn:aws:s3:::test-bucket-2"
        arn_items = "arn:aws:s3:::test-bucket-2/*"
    }]
    error_message = "locals.upload_buckets did not match expected value"
  }

  assert {
    condition     = length(aws_iam_role.scan_files) == 1
    error_message = "aws_iam_role.scan_files length did not match expected value"
  }

  assert {
    condition = aws_iam_role.scan_files[0].assume_role_policy == jsonencode(
      {
        "Statement" : [
          {
            "Action" : "sts:AssumeRole",
            "Effect" : "Allow",
            "Principal" : {
              "AWS" : [
                "arn:aws:iam::806545929748:role/s3-scan-object",
                "arn:aws:iam::806545929748:role/scan-files-api"
              ]
            }
          }
        ],
        "Version" : "2012-10-17"
      }
    )
    error_message = "aws_iam_role.scan_files[0].assume_role_policy length did not match expected value"
  }

  assert {
    condition     = length(aws_iam_policy.scan_files) == 1
    error_message = "aws_iam_policy.scan_files length did not match expected value"
  }

  assert {
    condition = aws_iam_policy.scan_files[0].policy == jsonencode(
      {
        "Statement" : [
          {
            "Action" : [
              "s3:PutObjectVersionTagging",
              "s3:PutObjectTagging",
              "s3:ListBucket",
              "s3:GetObjectVersionTagging",
              "s3:GetObjectVersion",
              "s3:GetObjectTagging",
              "s3:GetObject",
              "s3:GetBucketLocation",
              "s3:DeleteObjectVersionTagging",
              "s3:DeleteObjectTagging"
            ],
            "Effect" : "Allow",
            "Resource" : [
              "arn:aws:s3:::test-bucket-2/*",
              "arn:aws:s3:::test-bucket-2",
              "arn:aws:s3:::test-bucket-1/*",
              "arn:aws:s3:::test-bucket-1"
            ]
          }
        ],
        "Version" : "2012-10-17"
      }
    )
    error_message = "aws_iam_policy.scan_files[0].policy did not match expected value"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.scan_files) == 1
    error_message = "aws_iam_role_policy_attachment.scan_files length did not match expected value"
  }

  assert {
    condition = aws_kms_key.s3_scan_object_queue.policy == jsonencode(
      {
        "Statement" : [
          {
            "Action" : "kms:*",
            "Effect" : "Allow",
            "Principal" : {
              "AWS" : "arn:aws:iam::${run.setup.account_id}:root"
            },
            "Resource" : "*"
          },
          {
            "Action" : [
              "kms:GenerateDataKey*",
              "kms:Decrypt"
            ],
            "Effect" : "Allow",
            "Principal" : {
              "AWS" : "arn:aws:iam::806545929748:role/s3-scan-object",
              "Service" : "s3.amazonaws.com"
            },
            "Resource" : "*"
          }
        ],
        "Version" : "2012-10-17"
      }
    )
    error_message = "aws_kms_key.s3_scan_object_queue.policy did not match expected value"
  }

  assert {
    condition     = length(aws_s3_bucket_policy.upload_bucket) == 2
    error_message = "aws_s3_bucket_policy.upload_bucket length did not match expected value"
  }

  assert {
    condition     = aws_s3_bucket_policy.upload_bucket[0].bucket == "test-bucket-1"
    error_message = "aws_s3_bucket_policy.upload_bucket[0].bucket did not match expected value"
  }

  assert {
    condition     = aws_s3_bucket_policy.upload_bucket[1].bucket == "test-bucket-2"
    error_message = "aws_s3_bucket_policy.upload_bucket[1].bucket did not match expected value"
  }

  assert {
    condition     = length(aws_s3_bucket_notification.s3_scan_object) == 2
    error_message = "aws_s3_bucket_notification.s3_scan_object length did not match expected value"
  }

  assert {
    condition     = aws_s3_bucket_notification.s3_scan_object[0].bucket == "test-bucket-1"
    error_message = "aws_s3_bucket_notification.s3_scan_object[0].bucket did not match expected value"
  }

  assert {
    condition     = aws_s3_bucket_notification.s3_scan_object[1].bucket == "test-bucket-2"
    error_message = "aws_s3_bucket_notification.s3_scan_object[1].bucket did not match expected value"
  }
}

run "default_apply" {
  variables {
    s3_upload_bucket_names = [run.setup.scan_files_bucket_id]
  }

  assert {
    condition = aws_sqs_queue_policy.s3_scan_object.policy == jsonencode(
      {
        "Statement" : [
          {
            "Action" : "sqs:SendMessage",
            "Condition" : {
              "ArnEquals" : {
                "aws:SourceArn" : "arn:aws:s3:::${run.setup.scan_files_bucket_id}"
              }
            },
            "Effect" : "Allow",
            "Principal" : {
              "Service" : "s3.amazonaws.com"
            },
            "Resource" : "arn:aws:sqs:${run.setup.region}:${run.setup.account_id}:s3-scan-object",
            "Sid" : "S3sendToSQS"
          },
          {
            "Action" : [
              "sqs:ReceiveMessage",
              "sqs:GetQueueAttributes",
              "sqs:DeleteMessage"
            ],
            "Effect" : "Allow",
            "Principal" : {
              "AWS" : "arn:aws:iam::806545929748:role/s3-scan-object"
            },
            "Resource" : "arn:aws:sqs:${run.setup.region}:${run.setup.account_id}:s3-scan-object",
            "Sid" : "LambdaTriggerFromSQS"
          }
        ],
        "Version" : "2012-10-17"
      }
    )
    error_message = "aws_sqs_queue_policy.s3_scan_object.policy did not match expected value"
  }

  assert {
    condition = aws_s3_bucket_policy.upload_bucket[0].policy == jsonencode(
      {
        "Statement" : [
          {
            "Action" : [
              "s3:PutObjectVersionTagging",
              "s3:PutObjectTagging"
            ],
            "Effect" : "Allow",
            "Principal" : {
              "AWS" : "arn:aws:iam::${run.setup.account_id}:role/ScanFilesGetObjects"
            },
            "Resource" : "arn:aws:s3:::${run.setup.scan_files_bucket_id}/*"
          },
          {
            "Action" : [
              "s3:ListBucket",
              "s3:GetObjectVersionTagging",
              "s3:GetObjectVersion",
              "s3:GetObjectTagging",
              "s3:GetObject",
              "s3:GetBucketLocation"
            ],
            "Effect" : "Allow",
            "Principal" : {
              "AWS" : "arn:aws:iam::${run.setup.account_id}:role/ScanFilesGetObjects"
            },
            "Resource" : [
              "arn:aws:s3:::${run.setup.scan_files_bucket_id}/*",
              "arn:aws:s3:::${run.setup.scan_files_bucket_id}"
            ]
          }
        ],
        "Version" : "2012-10-17"
      }
    )
    error_message = "aws_s3_bucket_policy.upload_bucket[0].policy did not match expected value"
  }
}
