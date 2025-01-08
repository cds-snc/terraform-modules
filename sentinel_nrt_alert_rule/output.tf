output "alert_rule_id" {
  description = "The ID of the NRT alert rule."
  value       = azurerm_sentinel_alert_rule_nrt.this.id
}
