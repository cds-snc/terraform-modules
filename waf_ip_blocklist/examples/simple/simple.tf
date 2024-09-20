
module "simple" {
  source = "../../"

  service_name                = "simple"
  athena_query_results_bucket = "s3-athena-query-results-bucket"
  billing_tag_value           = "simple"
}

