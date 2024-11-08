output "s3_bucket_id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.this.id
}

output "s3_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = aws_s3_bucket.this.arn
}

output "s3_bucket_region" {
  description = "The AWS region this bucket resides in."
  value       = aws_s3_bucket.this.region
}

output "route_53_hosted_zone_id" {
  description = "The Route53 hosted zone ID."
  value       = var.is_create_hosted_zone ? aws_route53_zone.hosted_zone[0].zone_id : var.hosted_zone_id
}
