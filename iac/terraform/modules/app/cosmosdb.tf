variable "cosmos_db_kind" {
  type    = string
  default = "GlobalDocumentDB"
}

variable "cosmos_db_free_tier" {
  type    = bool
  default = true
}

variable "cosmos_db_database_throughput" {
  type    = number
  default = 400
}

resource "azurerm_cosmosdb_account" "app" {
  name                = "cosmos-${local.identifier}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  offer_type          = "Standard"
  kind                = var.cosmos_db_kind

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.resource_group.location
    failover_priority = 0
  }

  enable_free_tier = var.cosmos_db_free_tier
  # capabilities {
  #   name = "EnableServerless"
  # }

  public_network_access_enabled     = false
  is_virtual_network_filter_enabled = true
  virtual_network_rule {
    id = var.virtual_network_subnets.app.id
  }
}

resource "azurerm_cosmosdb_sql_database" "app" {
  name                = "app"
  resource_group_name = var.resource_group.name
  account_name        = azurerm_cosmosdb_account.app.name
  throughput          = var.cosmos_db_database_throughput
}

resource "azurerm_monitor_diagnostic_setting" "cosmosdb_account_app" {
  name                       = "diag-${azurerm_cosmosdb_account.app.name}"
  target_resource_id         = azurerm_cosmosdb_account.app.id
  log_analytics_workspace_id = var.log_analytics_workspace.id

  log {
    category = "DataPlaneRequests"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  log {
    category = "GremlinRequests"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "MongoRequests"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  log {
    category = "QueryRuntimeStatistics"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  log {
    category = "PartitionKeyStatistics"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  log {
    category = "PartitionKeyRUConsumption"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  log {
    category = "ControlPlaneRequests"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  log {
    category = "CassandraRequests"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }

  metric {
    category = "Requests"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }
}
