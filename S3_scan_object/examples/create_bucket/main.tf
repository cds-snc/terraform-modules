resource "random_id" "upload_bucket" {
  byte_length = 4
}

module "create_bucket" {
  source = "../../"

  product_name          = "create-bucket"
  s3_upload_bucket_name = "your-upload-bucket-name-${random_id.upload_bucket.hex}"
  scan_files_api_key    = "YouShouldDefinitelyKeepThisSecret"

  billing_tag_value = "terratest"
}
