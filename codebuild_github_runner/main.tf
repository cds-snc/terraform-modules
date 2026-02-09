/* 
* # CodeBuild GitHub runner
* Creates an AWS CodeBuild project that allows you to self-host serverless GitHub action runners.
*
* ## Authentication
* It is recommended that you create a [fine-grained personal access token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token) so that you can scope the permissions down to only what is required. The PAT should have the following permissions:
*
* - `Actions (read/write)`: required
* - `Administration (read/write)`: required
* - `Commit statuses (read/write)`: required
* - `Contents (read/write)`: optional, depends on runner tasks
* - `Metadata (read)`: required
* - `Pull requests (read/write)`: optional, depends on runner tasks
* - `Secrets (read)`: optional, depends on runner tasks
* - `Variables (read)`: optional, depends on runner tasks
* - `Webhooks (read/write)`: required
*
* ## Credit
* Inspiration for this module was taken from [cloudandthings/terraform-aws-github-runners](https://github.com/cloudandthings/terraform-aws-github-runners)
*/

resource "aws_codebuild_project" "this" {
  name           = var.project_name
  description    = "Self-hosted GitHub runner for ${var.github_repository_url}"
  build_timeout  = var.build_timeout
  queued_timeout = var.queued_timeout

  service_role = aws_iam_role.this.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type = "NO_CACHE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.this.name
      stream_name = var.project_name
    }
  }

  environment {
    compute_type                = var.environment_compute_type
    image                       = var.environment_image
    type                        = var.environment_type
    image_pull_credentials_type = var.environment_image_pull_credentials_type

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
      }
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repository_url
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }

    dynamic "auth" {
      for_each = local.is_github_codeconnection ? [1] : []
      content {
        type     = "CODECONNECTIONS"
        resource = data.aws_codestarconnections_connection.github_connection[0].arn
      }
    }
  }

  tags = local.common_tags
}

resource "aws_codebuild_source_credential" "this" {
  count       = local.is_github_pat ? 1 : 0
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_personal_access_token
}

resource "aws_codebuild_webhook" "this" {
  project_name = aws_codebuild_project.this.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "WORKFLOW_JOB_QUEUED"
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/codebuild/${var.project_name}"
  retention_in_days = "14"
}