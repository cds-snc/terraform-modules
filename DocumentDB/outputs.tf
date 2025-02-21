# Output values for the DocumentDB cluster

output "docdb_cluster_id" {
  description = "The document db cluster id"
  value       = var.enable ? aws_docdb_cluster.this[0].id : null
}

output "cluster_name" {
  description = "The document db cluster name"
  value       = var.enable ? aws_docdb_cluster.this[0].cluster_identifier:null

}

output "docdb_cluster_arn" {
  description = "The document db cluster arn"
  value       = var.enable ? aws_docdb_cluster.this[0].arn : null
}

output "docdb_port" {
  description = "The document db port"
  value       = var.enable ? aws_docdb_cluster.this[0].port:null
}

output "docdb_endpoint" {
  description = "The document db endpoint"
  sensitive   = true
  value       = var.enable ? aws_docdb_cluster.this[0].endpoint:null
}
