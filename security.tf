data "azurerm_client_config" "current" {}

# 18. Key Vault
resource "azurerm_key_vault" "key_vault" {
  name                = "kv-centralized"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                  = "standard"
  soft_delete_retention_days = 30

  access_policy {
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete"]
  }

  tags = var.tags
}

# Encryption Policy
#resource "azurerm_policy_definition" "encryption_policy" {
 # name         = "enforce-encryption"
 # policy_type  = "BuiltIn"
#  display_name = "Enforce encryption on resources"
 ## mode         = "All"
#}
resource "azurerm_policy_definition" "encryption_policy" {
  name         = "enforce-encryption"
  policy_type  = "Custom"
  display_name = "Enforce Encryption for Storage Accounts"
  description  = "This policy ensures all storage accounts have encryption enabled."
  mode         = "All"

  policy_rule = jsonencode({
    if = {
      field = "type"
      equals = "Microsoft.Storage/storageAccounts"
    }
    then = {
      effect = "Deny"
    }
  })

  metadata = jsonencode({
    category = "Storage"
  })
}


resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = true
}


# 20. Synapse SQL Password Secret
resource "random_password" "synapse_sql_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric  = true
}


# 21. Additional Example Secret
resource "azurerm_key_vault_secret" "example_secret" {
  key_vault_id = azurerm_key_vault.key_vault.id
  name         = "example-password-${random_string.suffix.result}"
  value        = "your_secret_value"
}


# 51. Role Assignment for Key Vault Reader
resource "azurerm_role_assignment" "key_vault_reader" {
  principal_id         = var.service_principal_id
  role_definition_name = "Key Vault Reader"
  scope                = azurerm_key_vault.key_vault.id

  timeouts {
    create = "10m"
  }
}

# 52. Role Assignment for Databricks Admin
resource "azurerm_role_assignment" "databricks_admin" {
  scope                = azurerm_databricks_workspace.example.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.current.object_id

  depends_on = [azurerm_databricks_workspace.example]
}

# 53. Role Assignment Contributor for Service Principal
resource "azurerm_role_assignment" "example" {
  principal_id         = var.service_principal_id
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.rg.id
}

