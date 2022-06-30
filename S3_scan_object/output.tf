output "lambda_role_arn" {
  description = "ARN of the S3 scan object lambda role"
  value       = module.s3_scan_object.function_role_arn
}

output "s3_upload_bucket_arn" {
  description = "ARN of the S3 upload bucket"
  value       = local.upload_bucket_arn
}

output "s3_upload_bucket_name" {
  description = "Name of the S3 upload bucket"
  value       = local.upload_bucket_id
}

output "scan_files_assume_role_arn" {
  description = "ARN of the role assumed by the Scan Files API"
  value       = local.scan_files_assume_role_arn
}
