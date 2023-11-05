provider "aws" {
  region = "ca-central-1"
}

run "default_inputs" {
  command = plan

  variables {
    roles = [
      {
        name      = "read-only"
        repo_name = "terraform-modules"
        claim     = "ref:refs/heads/*"
      },
      {
        name      = "admin"
        repo_name = "platform-core-services"
        claim     = "ref:refs/heads/main"
      }
    ]
  }

  assert {
    condition = local.roles_kv == {
      "read-only" = {
        name      = "read-only"
        repo_name = "terraform-modules"
        claim     = "ref:refs/heads/*"
      },
      "admin" = {
        name      = "admin"
        repo_name = "platform-core-services"
        claim     = "ref:refs/heads/main"
      }
    }
    error_message = "Local roles key-value list did not match expected value"
  }

  assert {
    condition     = length(aws_iam_role.this) == 2
    error_message = "IAM role count did not match expected value"
  }

  assert {
    condition     = aws_iam_role.this["admin"].name == "admin"
    error_message = "IAM admin role name did not match expected value"
  }

  assert {
    condition     = aws_iam_role.this["read-only"].name == "read-only"
    error_message = "IAM read-only role name did not match expected value"
  }

  assert {
    condition = aws_iam_role.this["admin"].assume_role_policy == jsonencode({
      Statement = [
        {
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringLike = {
              "token.actions.githubusercontent.com:sub" = "repo:cds-snc/platform-core-services:ref:refs/heads/main"
            }
          }
          Effect = "Allow"
          Principal = {
            Federated = "arn:aws:iam::571510889204:oidc-provider/token.actions.githubusercontent.com"
          }
        },
      ]
      Version = "2012-10-17"
    })
    error_message = "IAM read-only role assume policy name did not match expected value"
  }

  assert {
    condition = aws_iam_role.this["read-only"].assume_role_policy == jsonencode({
      Statement = [
        {
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringLike = {
              "token.actions.githubusercontent.com:sub" = "repo:cds-snc/terraform-modules:ref:refs/heads/*"
            }
          }
          Effect = "Allow"
          Principal = {
            Federated = "arn:aws:iam::571510889204:oidc-provider/token.actions.githubusercontent.com"
          }
        },
      ]
      Version = "2012-10-17"
    })
    error_message = "IAM read-only role assume policy name did not match expected value"
  }
}
