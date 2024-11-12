module "simple" {
  source = "../../"

  s3_upload_bucket_names = [
    module.upload_bucket_one.s3_bucket_id,
    module.upload_bucket_two.s3_bucket_id
  ]

  billing_tag_value = "terratest"
}

resource "random_id" "upload_bucket" {
  byte_length = 4
}

module "upload_bucket_one" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v9.6.8"
  bucket_name       = "an-existing-upload-bucket-${random_id.upload_bucket.hex}"
  billing_tag_value = "terratest"

  versioning = {
    enabled = true
  }
}

module "upload_bucket_two" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v9.6.8"
  bucket_name       = "another-existing-upload-bucket-${random_id.upload_bucket.hex}"
  billing_tag_value = "terratest"

  versioning = {
    enabled = true
  }
}
