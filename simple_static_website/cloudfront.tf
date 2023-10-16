#
# Cloudfront distribution using the static website S3 bucket as its origin
#

resource "aws_cloudfront_origin_access_identity" "simple_static_website" {
  comment = "Allow CloudFront to reach the S3 bucket for domain ${var.domain_name_source}"
}

resource "aws_cloudfront_distribution" "simple_static_website" {
  http_version = "http2"

  origin {
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id   = "simple_static_website"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.simple_static_website.cloudfront_access_identity_path
    }
  }

  default_root_object = var.index_document

  enabled     = true
  aliases     = [var.domain_name_source]
  price_class = var.cloudfront_price_class

  default_cache_behavior {
    target_origin_id = "simple_static_website"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.common_tags
}
