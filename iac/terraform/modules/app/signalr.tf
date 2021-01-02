locals {
  signalr_service_sku      = var.environment == "dev" ? "Free_F1" : "Standard_S1"
  signalr_service_capacity = var.environment == "dev" ? 1 : 50
}

resource "azurerm_signalr_service" "app" {
  name                = "signalr-${var.identifier}-app-${var.environment}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  sku {
    name     = local.signalr_service_sku
    capacity = local.signalr_service_capacity
  }
}

resource "azurerm_monitor_diagnostic_setting" "signalr_service_app" {
  name                       = "diag-${azurerm_signalr_service.app.name}"
  target_resource_id         = azurerm_signalr_service.app.id
  log_analytics_workspace_id = var.log_analytics_workspace.id

  log {
    category = "AllLogs"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  metric {
    category = "Traffic"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  metric {
    category = "Errors"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }
}
