variable "vnet_address_space" {
  type    = string
  default = "10.0.0.0/16"
}

locals {
  subnets = cidrsubnets(var.vnet_address_space, 8, 8)
}

resource "azurerm_virtual_network" "shared" {
  name                = "vnet-${var.identifier}-${var.environment}"
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name
  address_space = [
    var.vnet_address_space
  ]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.shared.name
  virtual_network_name = azurerm_virtual_network.shared.name
  address_prefixes     = [local.subnets[0]]
}

resource "azurerm_subnet" "app" {
  name                 = "snet-${var.identifier}-app-${var.environment}"
  resource_group_name  = azurerm_resource_group.shared.name
  virtual_network_name = azurerm_virtual_network.shared.name
  address_prefixes     = [local.subnets[1]]

  delegation {
    name = "app"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }

  service_endpoints = [
    "Microsoft.AzureCosmosDB",
    "Microsoft.Storage"
  ]
}

resource "azurerm_monitor_diagnostic_setting" "virtual_network_shared" {
  name                       = "diag-${azurerm_virtual_network.shared.name}"
  target_resource_id         = azurerm_virtual_network.shared.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.shared.id

  log {
    category = "VMProtectionAlerts"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }
}
