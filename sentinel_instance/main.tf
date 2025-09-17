resource "azurerm_log_analytics_workspace" "this" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days

  tags = merge(var.tags, local.common_tags)
}

resource "azurerm_management_lock" "log_analytics_readonly" {
  count      = var.enable_log_analytics_lock ? 1 : 0
  name       = "${azurerm_log_analytics_workspace.this.name}-readonly-lock"
  scope      = azurerm_log_analytics_workspace.this.id
  lock_level = "ReadOnly"
  notes      = "Read-only lock for Log Analytics Workspace"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "this" {
  workspace_id = azurerm_log_analytics_workspace.this.id
}
