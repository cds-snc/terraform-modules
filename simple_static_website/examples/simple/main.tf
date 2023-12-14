module "website" {
  source = "../../"

  domain_name_source = "example.com"
  billing_tag_value  = "simple-static-website"

  providers = {
    aws           = aws
    aws.dns       = aws # For scenarios where there is a dedicated DNS provder.
    aws.us-east-1 = aws.us-east-1
  }
}
