terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.41"
    }
  }
}

provider "azurerm" {
  features {}
}

module "shared" {
  source      = "./modules/shared"
  identifier  = var.identifier
  environment = var.environment
  location    = var.location
}

module "app" {
  source                  = "./modules/app"
  resource_group          = module.shared.resource_group
  identifier              = var.identifier
  environment             = var.environment
  virtual_network_subnets = module.shared.virtual_network_subnets
  log_analytics_workspace = module.shared.log_analytics_workspace
}
