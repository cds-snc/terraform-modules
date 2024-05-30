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
      query_string = var.cloudfront_query_string_forwarding

      cookies {
        forward = "none"
      }
    }

    dynamic "lambda_function_association" {
      for_each = var.lambda_function_association

      content {
        event_type   = lookup(lambda_function_association.value, "event_type", null)
        include_body = lookup(lambda_function_association.value, "include_body", false)
        lambda_arn   = lookup(lambda_function_association.value, "lambda_arn", null)
      }
    }

    # Function association 
    dynamic "function_association" {
      for_each = var.function_association

      content {
        event_type   = lookup(function_association.value, "event_type", null)
        function_arn = lookup(function_association.value, "function_arn", null)
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 86400
  }

  dynamic "custom_error_response" {
    for_each = var.single_page_app ? [
      {
        error_code            = 403,
        response_page_path    = "/${var.index_document}",
        error_caching_min_ttl = 300,
        response_code         = 200
      }
    ] : var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl != null ? custom_error_response.value.error_caching_min_ttl : 300
      response_code         = custom_error_response.value.response_code != null ? custom_error_response.value.response_code : 200
      response_page_path    = custom_error_response.value.response_page_path
    }
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

  web_acl_id = var.web_acl_arn

  tags = local.common_tags
}
