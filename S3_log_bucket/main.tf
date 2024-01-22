/* 
* # S3 Bucket
* 
* This was adapted from the [terraform-aws-modules](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket)
* The License file for this module can be found in this directory.
*/

resource "aws_s3_bucket" "this" {
  # checkov:skip=CKV_AWS_145:Encryption using AWS managed key is acceptable
  # checkov:skip=CKV_AWS_144:Cross region replication is not required by default and may be unwanted
  # checkov:skip=CKV_AWS_18:Ths bucket is used for access logging for other buckets
  # checkov:skip=CKV_AWS_21:Versioning is not required for access logs
  # checkov:skip=CKV2_AWS_6:Public access blocks are attached to policy which trickles down to this
  # checkov:skip=CKV_AWS_143:Object lock configuration is not needed for log buckets
  bucket        = var.bucket_name
  bucket_prefix = var.bucket_prefix

  tags          = merge(local.common_tags, var.tags)
  force_destroy = var.force_destroy

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
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.combined.json
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket_ownership_controls.this,
  ]

  bucket = aws_s3_bucket.this.id
  acl    = "log-delivery-write"
}

data "aws_iam_policy_document" "combined" {

  source_policy_documents = compact([
    var.attach_elb_log_delivery_policy ? data.aws_iam_policy_document.elb_log_delivery[0].json : "",
    var.attach_lb_log_delivery_policy ? data.aws_iam_policy_document.lb_log_delivery[0].json : "",
    data.aws_iam_policy_document.deny_insecure_transport.json
  ])
}

# AWS Load Balancer access log delivery policy
data "aws_elb_service_account" "this" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0
}

data "aws_iam_policy_document" "elb_log_delivery" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0

  statement {
    sid = "AWSELBLogDeliveryWrite"

    principals {
      type        = "AWS"
      identifiers = data.aws_elb_service_account.this.*.arn
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}


# ALB/NLB
data "aws_iam_policy_document" "lb_log_delivery" {
  count = var.attach_lb_log_delivery_policy ? 1 : 0

  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      aws_s3_bucket.this.arn,
    ]

  }
}

data "aws_iam_policy_document" "deny_insecure_transport" {
  statement {
    sid    = "denyInsecureTransport"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  # Chain resources (s3_bucket -> s3_bucket_policy -> s3_bucket_public_access_block)
  # to prevent "A conflicting conditional operation is currently in progress against this resource."
  bucket = aws_s3_bucket_policy.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket_policy.this.id

  versioning_configuration {
    status = var.versioning_status
  }
}


module "sentinel_forwarder" {
  source = "../sentinel_forwarder"

  count = var.configure_sentinel_forwarder ? 1 : 0

  function_name = "${aws_s3_bucket.this.id}-sentinel-forwarder"
  customer_id   = var.customer_id
  shared_key    = var.shared_key

  layer_arn = "arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:79"

  log_type = local.sentinel_forwarder.log_type

  s3_sources = [
    {
      bucket_arn    = local.sentinel_forwarder.bucket_arn
      bucket_id     = local.sentinel_forwarder.bucket_id
      filter_prefix = local.sentinel_forwarder.filter_prefix
      kms_key_arn   = local.sentinel_forwarder.kms_key_arn
    }
  ]

  billing_tag_key   = var.billing_tag_key
  billing_tag_value = var.billing_tag_value
}