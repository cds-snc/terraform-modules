/* 
* # S3_scan_object
* Lambda function that triggers a [scan](https://scan-files.alpha.canada.ca) of newly created S3 objects and updates the object with the scan results via an SNS topic subscription.
* 
* The function is invoked by `s3:ObjectCreated:*` events and messages published to its SNS `s3-object-scan-complete` topic.
*
* ## ⚠️ Notes
* - You will need a Scan Files API key to use this module.
* - Your AWS account must be part of our organization to use the default `lambda_ecr_arn` and `lambda_image_uri`.  To work around this, you can build your own Docker image using the code in [cds-snc/scan-files/module/s3-scan-object](https://github.com/cds-snc/scan-files/tree/main/module/s3-scan-object).
*/

module "s3_scan_object" {
  source = "github.com/cds-snc/terraform-modules?ref=v3.0.2//lambda"

  name      = "s3-scan-object-${var.product_name}"
  image_uri = var.lambda_image_uri
  ecr_arn   = var.lambda_ecr_arn
  memory    = 512
  timeout   = 15

  reserved_concurrent_executions = 3

  environment_variables = {
    AWS_ACCOUNT_ID                = local.account_id
    SCAN_FILES_URL                = var.scan_files_url
    SCAN_FILES_API_KEY_SECRET_ARN = var.scan_files_api_key_secret_arn
    SNS_SCAN_COMPLETE_TOPIC_ARN   = aws_sns_topic.scan_complete.arn
  }

  policies = [
    data.aws_iam_policy_document.s3_scan_object.json
  ]

  billing_tag_value = var.billing_tag_value
}

#
# Lambda IAM policies
#
data "aws_iam_policy_document" "s3_scan_object" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      var.scan_files_api_key_secret_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      var.scan_files_api_key_kms_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObjectTagging",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging"
    ]
    resources = [
      local.upload_bucket_arn,
      "${local.upload_bucket_arn}/*",
    ]
  }
}
