resource "random_pet" "buckets" {
  length = 2
}

module "access_logs" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=main"
  bucket_name       = "terraform-modules-lb-access-logs-${random_pet.buckets.id}"
  force_destroy     = true
  billing_tag_value = "test"
}

module "athena_bucket" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=main"
  bucket_name       = "terraform-modules-athena-database-bucket-${random_pet.buckets.id}"
  force_destroy     = true
  billing_tag_value = "test"
}

output "access_logs_bucket_name" {
  value = module.access_logs.s3_bucket_id
}

output "athena_bucket_name" {
  value = module.athena_bucket.s3_bucket_id
}