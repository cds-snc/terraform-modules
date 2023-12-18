data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "random_id" "scan_files" {
  byte_length = 4
}

module "scan_files" {
  source            = "../../../S3"
  bucket_name       = "an-existing-upload-bucket-${random_id.scan_files.hex}"
  billing_tag_value = "SRE"

  versioning = {
    enabled = true
  }
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = data.aws_region.current.name
}

output "scan_files_bucket_id" {
  value = module.scan_files.s3_bucket_id
}
