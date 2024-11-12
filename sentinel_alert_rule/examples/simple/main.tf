terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.117.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    template_deployment {
      delete_nested_items_during_deletion = false
    }
  }

}

data "azurerm_resource_group" "logging_rg" {
  name = "example-log-analytics-rg"
}

data "azurerm_log_analytics_workspace" "workspace" {
  name                = "example-log-analytics-workspace"
  resource_group_name = data.azurerm_resource_group.logging_rg.name
}

