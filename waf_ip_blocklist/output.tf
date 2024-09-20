output "ipv4_blocklist_arn" {
  description = "The ARN of the IP blocklist"
  value       = aws_wafv2_ip_set.ipv4_blocklist.arn
}