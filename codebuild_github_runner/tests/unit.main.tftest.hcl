provider "aws" {
  region = "ca-central-1"
}

variables {
  project_name          = "simple"
  github_repository_url = "https://github.com/cds-snc/terraform-modules.git"
}

run "test_case" {
  command = plan
}
