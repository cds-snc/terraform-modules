/* 
* # CodeBuild GitHub runner
*
* Creates an AWS CodeBuild project that allows you to self-host serverless GitHub action runners.
*
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
  }

  tags = local.common_tags
}

resource "aws_codebuild_source_credential" "this" {
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

  depends_on = [aws_codebuild_source_credential.this]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/codebuild/${var.project_name}"
  retention_in_days = "14"
}