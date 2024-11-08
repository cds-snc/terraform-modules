resource "aws_acm_certificate" "cloudfront" {
  count    = var.is_create_certificate ? 1 : 0
  provider = aws.us-east-1

  domain_name               = var.domain_name_source
  subject_alternative_names = ["*.${var.domain_name_source}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}

resource "aws_route53_record" "cloudfront_certificate_validation" {
  zone_id  = local.hosted_zone_id
  provider = aws.dns

  for_each = {
    for dvo in local.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = 60
}

resource "aws_acm_certificate_validation" "cloudfront" {
  count                   = var.is_create_certificate ? 1 : 0
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cloudfront[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cloudfront_certificate_validation : record.fqdn]
}
