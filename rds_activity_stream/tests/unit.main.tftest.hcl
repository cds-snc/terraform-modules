provider "aws" {
  region = "ca-central-1"
}

variables {
  rds_stream_name = "terraform-tests"
  rds_cluster_arn = "arn:aws:rds:ca-central-1:123456789012:cluster:test-cluster"
}

run "test_case" {
  command = plan
}
