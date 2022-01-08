output "role_arn" {
  description = <<-EOF
  This is the arn of the IAM Role that will be authenticated using OICD.
  This is needed for assigning roles to that authenticated IAM Role
  EOF
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "(Optional) The name of the role that will be impersonated using OICD"
  value       = aws_iam_role.this.name
}