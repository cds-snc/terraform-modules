resource "aws_route53_zone" "hosted_zone" {
  count = local.is_create_hosted_zone ? 1 : 0
  name  = var.domain_name_source
  tags  = local.common_tags
}

resource "aws_route53_record" "cloudfront_alias" {
  zone_id = local.hosted_zone_id
  name    = var.domain_name_source
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.simple_static_website.domain_name
    zone_id                = aws_cloudfront_distribution.simple_static_website.hosted_zone_id
    evaluate_target_health = false
  }
}
