# Output values for the DocumentDB cluster

output "docdb_cluster_id" {
  description = "The document db cluster id"
  value       = aws_docdb_cluster.this[0].id
}

output "cluster_name" {
  description = "The document db cluster name"
  value       = aws_docdb_cluster.this[0].cluster_identifier

}

output "docdb_cluster_arn" {
  description = "The document db cluster arn"
  value       = aws_docdb_cluster.this[0].arn
}

output "docdb_port" {
  description = "The document db port"
  value       = aws_docdb_cluster.this[0].port
}

output "docdb_endpoint" {
  description = "The document db endpoint"
  sensitive   = true
  value       = aws_docdb_cluster.this[0].endpoint
}
