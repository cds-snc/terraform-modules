#
# Cloudfront distribution using the Lambda's function URL as its origin
#
resource "aws_cloudfront_distribution" "redirector" {
  http_version = "http2"

  origin {
    origin_id   = "redirector"
    domain_name = trimsuffix(trimprefix(aws_lambda_function_url.redirector.function_url, "https://"), "/")

    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled     = true
  aliases     = [var.domain_name_source]
  price_class = var.cloudfront_price_class

  default_cache_behavior {
    target_origin_id = "redirector"
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
