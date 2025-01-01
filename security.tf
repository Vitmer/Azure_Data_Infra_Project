data "azurerm_client_config" "current" {}

# 18. Key Vault
resource "azurerm_key_vault" "key_vault" {
  name                = "kv-centralized"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                  = "standard"
  soft_delete_retention_days = 30

  tags = var.tags
}

# 19. Access Policy for Terraform
resource "azurerm_key_vault_access_policy" "terraform_access" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete"]

  lifecycle {
    ignore_changes = [secret_permissions]
  }
}

# 20. Random Password for Synapse SQL
resource "random_password" "synapse_sql_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric  = true
}

# 21. Synapse SQL Password Secret
resource "azurerm_key_vault_secret" "synapse_sql_password" {
  depends_on = [azurerm_key_vault_access_policy.terraform_access]

  name         = "synapse-sql-password"
  value        = random_password.synapse_sql_password.result
  key_vault_id = azurerm_key_vault.key_vault.id

  lifecycle {
    ignore_changes = [value]
  }
}

# 22. Example Secret
resource "azurerm_key_vault_secret" "example_secret" {
  name         = "example-password"
  key_vault_id = azurerm_key_vault.key_vault.id
  value        = "new-secret-value"

  lifecycle {
    ignore_changes = [value]
  }
}

# 23. Output for Synapse Password
output "synapse_sql_password" {
  value     = random_password.synapse_sql_password.result
  sensitive = true
}
