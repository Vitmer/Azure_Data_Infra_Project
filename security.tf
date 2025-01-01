data "azurerm_client_config" "current" {}

# 18. Key Vault
resource "random_id" "unique_suffix" {
  byte_length = 4
}

resource "azurerm_key_vault" "key_vault" {
  name                = "kv-central-${substr(random_id.unique_suffix.hex, 0, 10)}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                  = "standard"
  soft_delete_retention_days = 7

  tags = var.tags
}

# 19. Access Policy for Terraform
resource "azurerm_key_vault_access_policy" "terraform_access" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = var.tenant_id
  object_id    = var.service_principal_id

  secret_permissions = ["Get", "List", "Set", "Delete"]

  lifecycle {
    ignore_changes = [secret_permissions]
  }
}

# 21. Synapse SQL Password Secret
resource "azurerm_key_vault_secret" "synapse_sql_password" {
  depends_on = [azurerm_key_vault_access_policy.terraform_access]

  name         = "synapse-sql-password"
  value        = var.synapse_sql_password
  key_vault_id = azurerm_key_vault.key_vault.id
}

# 22. Example Secret
resource "azurerm_key_vault_secret" "example_secret" {
  name         = "example-password"
  value        = var.example_password
  key_vault_id = azurerm_key_vault.key_vault.id
}


