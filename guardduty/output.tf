output "guardduty_detector" {
  description = "The GuardDuty detector."
  value       = aws_guardduty_detector.this.id
}