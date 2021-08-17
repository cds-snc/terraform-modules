
module "bucket" {
  source            = "../../../S3/"
  billing_tag_value = "terratest"
  bucket_name       = var.name

  logging = {
    target_bucket = module.log_bucket.s3_bucket_id
  }

}

module "log_bucket" {
  source            = "../../"
  billing_tag_value = "terratest"
  bucket_name       = "${var.name}-log"
  force_destroy     = true
}

variable "name" {
  type = string
}

output "id" {
  value = module.log_bucket.s3_bucket_id
}

output "arn" {
  value = module.log_bucket.s3_bucket_arn
}

output "region" {
  value = module.log_bucket.s3_bucket_region
}
