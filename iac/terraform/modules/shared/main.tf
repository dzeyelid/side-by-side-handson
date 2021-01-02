output "resource_group" {
  value = {
    name     = azurerm_resource_group.shared.name
    location = azurerm_resource_group.shared.location
  }
}

output "virtual_network_subnets" {
  value = {
    app = {
      id = azurerm_subnet.app.id
    }
  }
}

output "log_analytics_workspace" {
  value = {
    id   = azurerm_log_analytics_workspace.shared.id
    name = azurerm_log_analytics_workspace.shared.name
  }
}
