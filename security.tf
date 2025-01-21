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

# 19. Access Policy for Terraform
#resource "azurerm_key_vault_access_policy" "terraform_access" {
#  key_vault_id = azurerm_key_vault.key_vault.id
 # tenant_id    = data.azurerm_client_config.current.tenant_id
 # object_id    = data.azurerm_client_config.current.object_id

#  secret_permissions = ["Get", "List", "Set", "Delete"]

 # lifecycle {
 #   ignore_changes = [key_vault_id, object_id, secret_permissions]
 # }
#}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = true
}

#resource "azurerm_key_vault_access_policy" "terraform_access" {
#  key_vault_id = azurerm_key_vault.key_vault.id
 # tenant_id    = data.azurerm_client_config.current.tenant_id
#  object_id    = data.azurerm_client_config.current.object_id

#  secret_permissions = ["Get", "List", "Set", "Delete"]

#  lifecycle {
 #   prevent_destroy = true
 # }
#}



# 20. Synapse SQL Password Secret
resource "random_password" "synapse_sql_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric  = true
}

#resource "azurerm_key_vault_secret" "synapse_sql_password" {
 # depends_on = [azurerm_key_vault_access_policy.terraform_access]

#  key_vault_id = azurerm_key_vault.key_vault.id
#  name         = "synapse-sql-password"
#  value        = var.synapse_sql_password

#}

# 21. Additional Example Secret
resource "azurerm_key_vault_secret" "example_secret" {
  key_vault_id = azurerm_key_vault.key_vault.id
  name         = "example-password-${random_string.suffix.result}"
  value        = "your_secret_value"
}

#resource "azurerm_key_vault_secret" "example_secret" {
 # name         = "example-password"
#  key_vault_id = azurerm_key_vault.key_vault.id
 # value        = "new-secret-value"

 # lifecycle {
#    ignore_changes = [value]
#    prevent_destroy = true
 # }
#}

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

