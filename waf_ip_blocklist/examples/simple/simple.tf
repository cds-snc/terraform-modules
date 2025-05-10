module "simple" {
  source = "../../"

  service_name                = "test-app"
  athena_query_results_bucket = "test-app-athena-bucket"
  athena_query_source_bucket  = "test-app-waf-logs-bucket"
  waf_rule_ids_skip           = ["RuleIdOne", "RuleIdTwo"] # These rules will not count towards blocking an IP
  billing_tag_value           = "test-app"
}

module "cloudfront" {
  source = "../../"

  service_name                = "test-app"
  athena_query_results_bucket = "test-app-athena-bucket"
  athena_query_source_bucket  = "test-app-waf-logs-bucket"
  billing_tag_value           = "test-app"

  waf_scope     = "CLOUDFRONT"
  athena_region = "ca-central-1"

  providers = {
    aws = aws.us-east-1
  }
}