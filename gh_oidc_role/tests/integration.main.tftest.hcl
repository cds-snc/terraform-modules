provider "aws" {
  region = "ca-central-1"
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "custom_inputs" {
  variables {
    roles = [
      {
        name      = "admin"
        repo_name = "platform-core-services"
        claim     = "ref:refs/heads/main"
      }
    ]
    org_name      = "snc-cds"
    assume_policy = run.setup.service_principal_assume
  }

  assert {
    condition = local.roles_kv == {
      "admin" = {
        name      = "admin"
        repo_name = "platform-core-services"
        claim     = "ref:refs/heads/main"
      }
    }
    error_message = "Local roles key-value list did not match expected value"
  }

  assert {
    condition     = length(aws_iam_role.this) == 1
    error_message = "IAM role count did not match expected value"
  }

  assert {
    condition = aws_iam_role.this["admin"].assume_role_policy == jsonencode({
      Statement = [
        {
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringLike = {
              "token.actions.githubusercontent.com:sub" = "repo:snc-cds/platform-core-services:ref:refs/heads/main"
            }
          }
          Effect = "Allow"
          Principal = {
            Federated = "arn:aws:iam::${run.setup.account_id}:oidc-provider/token.actions.githubusercontent.com"
          }
        },
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "config.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    })
    error_message = "IAM read-only role assume policy name did not match expected value"
  }
}