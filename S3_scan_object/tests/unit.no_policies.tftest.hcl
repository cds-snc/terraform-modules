provider "aws" {
  region = "ca-central-1"
}

# Do not create the IAM role or S3 bucket policies
run "no_policies" {
  command = plan

  variables {
    s3_upload_bucket_names         = ["test-bucket-3"]
    s3_upload_bucket_policy_create = false
    s3_scan_object_role_arn        = "arn:aws:iam::123456789012:role/s3_scan_object_role_arn"
    scan_files_role_arn            = "arn:aws:iam::123456789012:role/scan_files_role_arn"
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
                "arn:aws:iam::123456789012:role/s3_scan_object_role_arn",
                "arn:aws:iam::123456789012:role/scan_files_role_arn"
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
    condition     = length(aws_iam_role_policy_attachment.scan_files) == 1
    error_message = "aws_iam_role_policy_attachment.scan_files length did not match expected value"
  }

  assert {
    condition     = length(aws_s3_bucket_policy.upload_bucket) == 0
    error_message = "aws_s3_bucket_policy.upload_bucket length did not match expected value"
  }

  assert {
    condition     = length(aws_s3_bucket_notification.s3_scan_object) == 1
    error_message = "aws_s3_bucket_notification.s3_scan_object length did not match expected value"
  }

  assert {
    condition     = aws_s3_bucket_notification.s3_scan_object[0].bucket == "test-bucket-3"
    error_message = "aws_s3_bucket_notification.s3_scan_object[0].bucket did not match expected value"
  }
}
