data "aws_codestarconnections_connection" "github_connection" {
  count = local.is_github_codeconnection ? 1 : 0
  name  = var.github_codeconnection_name
}