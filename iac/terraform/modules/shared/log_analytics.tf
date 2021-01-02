variable "log_analytics_sku" {
  type    = string
  default = "PerGB2018"
}

resource "azurerm_log_analytics_workspace" "shared" {
  name                = "log-${var.identifier}-${var.environment}"
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name
  sku                 = var.log_analytics_sku
}
