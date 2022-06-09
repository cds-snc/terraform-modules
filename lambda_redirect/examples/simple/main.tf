#
# Lambda redirect creating a new Route53 hosted zone and ACM certificate
#
module "lambda_redirect" {
  source = "../../"

  domain_name_source = "lambda-redirect.cdssandbox.xyz"
  redirect_url       = "https://digital.canada.ca"

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Terratest"

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}
