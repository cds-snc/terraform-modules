provider "aws" {
  region = "ca-central-1"
}

variables {
  project_name                 = "simple"
  github_repository_url        = "https://github.com/cds-snc/terraform-modules.git"
  github_personal_access_token = "this_should_be_secret"
  environment_variables = [
    {
      name  = "foo"
      value = "bar"
    }
  ]
}

run "plan" {
  command = plan

  assert {
    condition     = length(aws_codebuild_project.this.environment[0].environment_variable) == 1
    error_message = "Unexpected attribute length"
  }

  assert {
    condition     = aws_codebuild_project.this.environment[0].environment_variable[0].name == "foo"
    error_message = "Unexpected attribute value"
  }

  assert {
    condition     = aws_codebuild_project.this.environment[0].environment_variable[0].value == "bar"
    error_message = "Unexpected attribute value"
  }
}
