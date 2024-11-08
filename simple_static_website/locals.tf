locals {
  acm_certificate_arn       = var.is_create_certificate ? aws_acm_certificate_validation.cloudfront[0].certificate_arn : var.acm_certificate_arn
  domain_validation_options = var.is_create_certificate ? aws_acm_certificate.cloudfront[0].domain_validation_options : []
  hosted_zone_id            = var.is_create_hosted_zone ? aws_route53_zone.hosted_zone[0].zone_id : var.hosted_zone_id

  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
}
