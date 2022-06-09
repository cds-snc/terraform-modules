locals {
  is_create_certificate = length(var.acm_certificate_arn) == 0
  is_create_hosted_zone = length(var.hosted_zone_id) == 0

  acm_certificate_arn       = local.is_create_certificate ? aws_acm_certificate_validation.cloudfront[0].certificate_arn : var.acm_certificate_arn
  domain_validation_options = local.is_create_certificate ? aws_acm_certificate.cloudfront[0].domain_validation_options : []
  hosted_zone_id            = local.is_create_hosted_zone ? aws_route53_zone.hosted_zone[0].zone_id : var.hosted_zone_id
  lambda_function_name      = format("%.64s", "redirector-${replace(var.domain_name_source, ".", "-")}")

  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
}
