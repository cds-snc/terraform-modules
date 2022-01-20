locals {
  source_bucket_name      = "cds-terraform-modules-s3-repl-src-${random_pet.this.id}"
  destination_bucket_name = "cds-terraform-modules-s3-repl-dest-${random_pet.this.id}"
}

# Source bucket that replicates objects
module "source_bucket" {
  source            = "../../"
  billing_tag_value = "terratest"
  bucket_name       = local.source_bucket_name

  versioning = {
    enabled = true
  }

  replication_configuration = {
    role = aws_iam_role.replication.arn

    rules = [
      {
        id       = "replicate-all-the-things"
        status   = "Enabled"
        priority = 20

        filter = {
          prefix = ""
        }

        destination = {
          bucket = "arn:aws:s3:::${local.destination_bucket_name}"
        }
      }
    ]
  }
}

# Target bucket for the replication
module "destination_bucket" {
  source            = "../../"
  billing_tag_value = "terratest"
  bucket_name       = local.destination_bucket_name

  versioning = {
    enabled = true
  }
}

resource "random_pet" "this" {
  length = 2
}

output "source_bucket_id" {
  value = module.source_bucket.s3_bucket_id
}

output "destination_bucket_arn" {
  value = module.destination_bucket.s3_bucket_arn
}

output "replication_role_arn" {
  value = aws_iam_role.replication.arn
}
