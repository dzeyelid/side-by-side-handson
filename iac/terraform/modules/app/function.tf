variable "storage_account_kind" {
  type    = string
  default = "StorageV2"
}

variable "storage_account_tier" {
  type    = string
  default = "Standard"
}

variable "storage_account_replication_type" {
  type    = string
  default = "LRS"
}

variable "app_service_plan_tier" {
  type    = string
  default = "Standard"
}

variable "app_service_plan_size" {
  type    = string
  default = "S1"
}

resource "azurerm_storage_account" "app" {
  name                     = format("st%sapp%s", join("", split("-", var.identifier)), var.environment)
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_kind             = var.storage_account_kind
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type

  network_rules {
    default_action             = "Deny"
    bypass                     = ["Logging", "Metrics", "AzureServices"]
    virtual_network_subnet_ids = [var.virtual_network_subnets.app.id]
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_app" {
  name                       = "diag-${azurerm_storage_account.app.name}"
  target_resource_id         = azurerm_storage_account.app.id
  log_analytics_workspace_id = var.log_analytics_workspace.id

  metric {
    category = "Transaction"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }
}

resource "azurerm_application_insights" "app" {
  name                = "appi-${local.identifier}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  application_type    = "web"
}

resource "azurerm_app_service_plan" "app" {
  name                = "plan-${local.identifier}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  kind                = "App"

  sku {
    tier = var.app_service_plan_tier
    size = var.app_service_plan_size
  }
}

resource "azurerm_monitor_diagnostic_setting" "app_service_plan_app" {
  name                       = "diag-${azurerm_app_service_plan.app.name}"
  target_resource_id         = azurerm_app_service_plan.app.id
  log_analytics_workspace_id = var.log_analytics_workspace.id

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }
}

resource "azurerm_function_app" "app" {
  name                       = "func-${local.identifier}"
  location                   = var.resource_group.location
  resource_group_name        = var.resource_group.name
  app_service_plan_id        = azurerm_app_service_plan.app.id
  storage_account_name       = azurerm_storage_account.app.name
  storage_account_access_key = azurerm_storage_account.app.primary_access_key

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.app.instrumentation_key
    COSMOS_DB_CONNECTION_STRING    = azurerm_cosmosdb_account.app.connection_strings[0]
  }

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    ftps_state    = "Disabled"
    http2_enabled = true
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "app" {
  app_service_id = azurerm_function_app.app.id
  subnet_id      = var.virtual_network_subnets.app.id
}
