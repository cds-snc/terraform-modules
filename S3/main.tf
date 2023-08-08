/* 
* # S3 Bucket
* 
* This was adapted from the [terraform-aws-modules](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket)
* The License file for this module can be found in this directory
*/

resource "aws_s3_bucket" "this" {
  # checkov:skip=CKV_AWS_19:False-positive, bucket objects are encrypted, either using a CMK or the default S3 service key
  # checkov:skip=CKV_AWS_145:Encryption using AWS managed key is acceptable
  # checkov:skip=CKV_AWS_144:Cross region replication is not required by default and may be unwanted
  # checkov:skip=CKV_AWS_143:Object lock configuration is configurable
  # checkov:skip=CKV2_AWS_6:False-positive, a public access block is defined by `aws_s3_bucket_public_access_block.this`

  bucket        = var.bucket_name
  bucket_prefix = var.bucket_prefix

  acl = "private"

  tags          = merge(local.common_tags, var.tags)
  force_destroy = var.force_destroy


  dynamic "versioning" {
    for_each = length(keys(var.versioning)) == 0 ? [] : [var.versioning]

    content {
      enabled    = lookup(versioning.value, "enabled", null)
      mfa_delete = lookup(versioning.value, "mfa_delete", null)
    }
  }

  # dynamic "logging" {
  #   for_each = length(keys(var.logging)) == 0 ? [] : [var.logging]

  #   content {
  #     target_bucket = logging.value.target_bucket
  #     target_prefix = lookup(logging.value, "target_prefix", null)
  #   }
  # }

  dynamic "lifecycle_rule" {
    for_each = try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)

    content {
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = lifecycle_rule.value.enabled

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

    }
  }

  server_side_encryption_configuration {
    rule {
      bucket_key_enabled = var.kms_key_arn != null
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_arn
        sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"

      }
    }
  }

  # Max 1 block - replication_configuration
  dynamic "replication_configuration" {
    for_each = length(keys(var.replication_configuration)) == 0 ? [] : [var.replication_configuration]

    content {
      role = replication_configuration.value.role

      dynamic "rules" {
        for_each = replication_configuration.value.rules

        content {
          id                               = lookup(rules.value, "id", null)
          priority                         = lookup(rules.value, "priority", null)
          delete_marker_replication_status = lookup(rules.value, "delete_marker_replication_status", null)
          status                           = "Enabled"

          dynamic "destination" {
            for_each = length(keys(lookup(rules.value, "destination", {}))) == 0 ? [] : [lookup(rules.value, "destination", {})]

            content {
              bucket             = destination.value.bucket
              replica_kms_key_id = lookup(destination.value, "replica_kms_key_id", null)
              account_id         = lookup(destination.value, "account_id", null)

              dynamic "access_control_translation" {
                for_each = length(keys(lookup(destination.value, "access_control_translation", {}))) == 0 ? [] : [lookup(destination.value, "access_control_translation", {})]

                content {
                  owner = access_control_translation.value.owner
                }
              }
            }
          }

          dynamic "source_selection_criteria" {
            for_each = length(keys(lookup(rules.value, "source_selection_criteria", {}))) == 0 ? [] : [lookup(rules.value, "source_selection_criteria", {})]

            content {

              dynamic "sse_kms_encrypted_objects" {
                for_each = length(keys(lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {}))) == 0 ? [] : [lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {})]

                content {

                  enabled = sse_kms_encrypted_objects.value.enabled
                }
              }
            }
          }

          dynamic "filter" {
            for_each = length(keys(var.replication_configuration)) == 0 ? [] : [1]
            content {
              prefix = ""
            }
          }

        }
      }
    }
  }

  # Max 1 block - object_lock_configuration
  dynamic "object_lock_configuration" {
    for_each = length(keys(var.object_lock_configuration)) == 0 ? [] : [var.object_lock_configuration]

    content {
      object_lock_enabled = object_lock_configuration.value.object_lock_enabled

      dynamic "rule" {
        for_each = length(keys(lookup(object_lock_configuration.value, "rule", {}))) == 0 ? [] : [lookup(object_lock_configuration.value, "rule", {})]

        content {
          default_retention {
            mode  = lookup(lookup(rule.value, "default_retention", {}), "mode")
            days  = lookup(lookup(rule.value, "default_retention", {}), "days", null)
            years = lookup(lookup(rule.value, "default_retention", {}), "years", null)
          }
        }
      }
    }
  }

}

resource "aws_s3_bucket_public_access_block" "this" {
  # checkov:skip=CKV_AWS_54: `block_public_policy` controlled by a variable (default `true`)
  # checkov:skip=CKV_AWS_56: `restrict_public_bucket` controlled by a variable (default `true`)

  # Chain resources (s3_bucket -> s3_bucket_policy -> s3_bucket_public_access_block)
  # to prevent "A conflicting conditional operation is currently in progress against this resource."
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_logging" "this" {
  
  count = length(local.logging_configuration_objects)

  bucket        = aws_s3_bucket.this.id
  target_bucket = element(local.logging_configuration_objects, count.index).target_bucket
  target_prefix = element(local.logging_configuration_objects, count.index).target_prefix
}

module "s3_log_bucket" {
  source = "../S3_log_bucket"

  count = var.configure_critical_bucket_logs ? 1 : 0

  configure_sentinel_forwarder = local.s3_log_bucket.configure_sentinel_forwarder

  billing_tag_key   = local.s3_log_bucket.billing_tag_key
  billing_tag_value = local.s3_log_bucket.billing_tag_value

  bucket_name = local.s3_log_bucket.bucket_name

  customer_id = local.s3_log_bucket.customer_id
  shared_key  = local.s3_log_bucket.shared_key

}