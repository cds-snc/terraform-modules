
module "simple" {
  source = "../../"

  project_name          = "simple"
  github_repository_url = "https://github.com/cds-snc/terraform-modules.git"

  billing_tag_value = "Test"
}

