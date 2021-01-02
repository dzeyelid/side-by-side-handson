resource "azurerm_resource_group" "shared" {
  name     = "rg-${var.identifier}-${var.environment}"
  location = var.location
}
