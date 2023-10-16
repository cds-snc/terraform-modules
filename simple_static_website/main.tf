/* 
* # Simple static website
* The purpose of this module is to create a simple static website using S3 and CloudFront. 
* Access to the S3 bucket is restricted to CloudFront using an Origin Access Identity (OAI).
*
* ## Usage
* ```
* module "website" {
*  source  = "github.com/cds-snc/terraform-modules//simple_static_website"
*
*  domain_name_source = "example.com"
*  billing_tag_value  = "simple-static-website"
*
*  providers = {
*    aws           = aws
*    aws.us-east-1 = aws.us-east-1
*  }
* }
* ```
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

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.domain_name_source}-${random_string.suffix.result}"
}

resource "aws_s3_bucket_policy" "oai_policy" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_policy.json
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
