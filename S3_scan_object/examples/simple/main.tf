module "simple" {
  source = "../../"

  product_name          = "simple"
  s3_upload_bucket_name = module.upload_bucket.s3_bucket_id

  alarm_on_lambda_error     = true
  alarm_ok_sns_topic_arn    = aws_sns_topic.cloudwatch_alarms_ok.arn
  alarm_error_sns_topic_arn = aws_sns_topic.cloudwatch_alarms_chaos_and_madness.arn

  billing_tag_value = "terratest"

  log_level = "DEBUG"
}

resource "aws_sns_topic" "cloudwatch_alarms_ok" {
  name = "cloudwatch_alarms_ok"
}

resource "aws_sns_topic" "cloudwatch_alarms_chaos_and_madness" {
  name = "cloudwatch_alarms_chaos_and_madness"
}

resource "random_id" "upload_bucket" {
  byte_length = 4
}

module "upload_bucket" {
  source            = "github.com/cds-snc/terraform-modules?ref=v5.1.10//S3"
  bucket_name       = "an-existing-upload-bucket-${random_id.upload_bucket.hex}"
  billing_tag_value = "terratest"

  versioning = {
    enabled = true
  }
}
