# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    prevent_destroy = true  # Предотвращаем случайное удаление
  }

  tags = {
    Environment = "Production"
  }
}

# Storage Container
resource "azurerm_storage_container" "data_container" {
  name                  = "datacontainer"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}

# Storage Queue
resource "azurerm_storage_queue" "data_queue" {
  name                 = "dataqueue"
  storage_account_name = azurerm_storage_account.storage.name

  lifecycle {
    prevent_destroy = true
  }
}

# Storage Table
resource "azurerm_storage_table" "data_table" {
  name                 = "datatable"
  storage_account_name = azurerm_storage_account.storage.name

  lifecycle {
    prevent_destroy = true
  }
}