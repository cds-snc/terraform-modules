
module "bucket" {
  source            = "../../"
  billing_tag_value = "terratest"
  bucket_name       = "cds-terraform-modules-basic-bucket-${random_pet.this.id}"

  versioning = {
    enabled = true
  }
}

resource "random_pet" "this" {
  length = 2
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

output "public_access_block_id" {
  value = module.bucket.s3_bucket_public_access_block_id
}
