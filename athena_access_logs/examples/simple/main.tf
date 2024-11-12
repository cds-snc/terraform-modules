module "simple" {
  source = "../../"

  athena_bucket_name = module.athena_bucket.s3_bucket_id

  lb_access_queries_create  = true
  lb_access_log_bucket_name = module.access_logs.s3_bucket_id

  waf_access_queries_create  = true
  waf_access_log_bucket_name = module.access_logs.s3_bucket_id

  billing_tag_value = "Terratest"
}

resource "random_pet" "buckets" {
  length = 2
}

#
# Access log buckets.  This is just being used as an example.  In a real scenario
# you would set the `lb_access_log_bucket_name` and `waf_access_log_bucket_name` to
# the S3 buckets that your access logs are being sent to.
#
module "access_logs" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v9.6.8"
  bucket_name       = "terraform-modules-simple-access-logs-${random_pet.buckets.id}"
  force_destroy     = true
  billing_tag_value = "Terratest"
}

#
# Hold the Athena data
#
module "athena_bucket" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v9.6.8"
  bucket_name       = "terraform-modules-simple-athena-bucket-${random_pet.buckets.id}"
  force_destroy     = true
  billing_tag_value = "Terratest"
}
