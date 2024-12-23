data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                = "kv-example"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"
  soft_delete_retention_days = 7
}

resource "azurerm_key_vault_access_policy" "terraform_access" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete"]
}

resource "azurerm_key_vault_secret" "example_secret" {
  name         = "example-password"
  value        = var.synapse_sql_password
  key_vault_id = azurerm_key_vault.key_vault.id
}