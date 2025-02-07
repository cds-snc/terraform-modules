provider "aws" {
  region = "ca-central-1"
}

variables {
  project_name                 = "simple"
  github_repository_url        = "https://github.com/cds-snc/terraform-modules.git"
  github_personal_access_token = "this_should_be_secret"
}

run "test_case" {
  command = plan
}
