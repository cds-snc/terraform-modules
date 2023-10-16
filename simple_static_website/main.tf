/* # simple_static_website
*
*/


terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.9"
      configuration_aliases = [aws, aws.us-east-1]
    }
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.simple_static_website.iam_arn]
    }
  }
}

resource "aws_s3_bucket" "this" {
  bucket = var.domain_name_source
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}
