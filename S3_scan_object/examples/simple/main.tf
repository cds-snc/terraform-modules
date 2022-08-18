module "simple" {
  source = "../../"

  product_name          = "simple"
  s3_upload_bucket_name = module.upload_bucket.s3_bucket_id
  alarm_sns_topic_arn   = aws_sns_topic.cloudwatch_alarms.arn

  billing_tag_value = "terratest"
}

resource "aws_sns_topic" "cloudwatch_alarms" {
  name = "cloudwatch_alarms"
}

resource "random_id" "upload_bucket" {
  byte_length = 4
}

module "upload_bucket" {
  source            = "github.com/cds-snc/terraform-modules?ref=v3.0.8//S3"
  bucket_name       = "an-existing-upload-bucket-${random_id.upload_bucket.hex}"
  billing_tag_value = "terratest"

  versioning = {
    enabled = true
  }
}
