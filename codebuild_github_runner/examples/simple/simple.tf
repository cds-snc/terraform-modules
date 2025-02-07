
module "simple" {
  source = "../../"

  project_name                 = "simple"
  github_repository_url        = "https://github.com/cds-snc/terraform-modules.git"
  github_personal_access_token = "this_should_be_secret"

  billing_tag_value = "Test"
}

