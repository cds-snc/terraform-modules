provider "aws" {
  region = "ca-central-1"
}

variables {
  service_name                = "test"
  athena_query_results_bucket = "test-athena-query-results-bucket"
  athena_query_source_bucket  = "test-athena-query-source-bucket"
  billing_tag_value           = "test"
}

run "default" {
  command = plan
}
