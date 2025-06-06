provider "aws" {
  region = "ca-central-1"
}

variables {
}

run "test_case" {
  command = plan
}
