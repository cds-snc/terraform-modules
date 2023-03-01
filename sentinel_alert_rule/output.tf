output "alert_rule_id" {
  description = "The ID of the alert rule."
  value       = azurerm_sentinel_alert_rule_scheduled.this.id
}
