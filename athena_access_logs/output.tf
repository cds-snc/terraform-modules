output "athena_workgroup_name" {
  value       = aws_athena_workgroup.logs.name
  description = "The name of the Athena workgroup"
}

output "athena_database_name" {
  value       = aws_athena_database.logs.name
  description = "The name of the Athena database"
}
