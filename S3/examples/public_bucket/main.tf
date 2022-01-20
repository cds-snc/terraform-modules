
module "bucket" {
  source            = "../../"
  billing_tag_value = "terratest"
  bucket_name       = var.name

  block_public_policy     = false
  restrict_public_buckets = false

  versioning = {
    enabled = true
  }
}

variable "name" {
  type = string
}

output "id" {
  value = module.bucket.s3_bucket_id
}

output "arn" {
  value = module.bucket.s3_bucket_arn
}

output "domain_name" {
  value = module.bucket.s3_bucket_domain_name
}

output "regional_domain" {
  value = module.bucket.s3_bucket_regional_domain_name
}

output "region" {
  value = module.bucket.s3_bucket_region
}
