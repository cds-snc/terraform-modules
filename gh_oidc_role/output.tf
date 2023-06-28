output "roles" {
  description = "Returns all the roles created accessed by the name passed in to the module."
  value       = { for r in aws_iam_role.this : r.name => r }
}
