#
# Lambda redirect that returns forbidden for a domain
#
module "lambda_redirect" {
  source = "../../"

  domain_name_source   = "lambda-redirect.cdssandbox.xyz"
  response_status_code = 403
  response_headers     = {}

  # Use an existing us-east-1 ACM certificate and hosted zone
  acm_certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  hosted_zone_id         = "SomeHostedZoneId"
  cloudfront_price_class = "PriceClass_All"

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Terratest"

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}
