# 6. Network Security Group

# 21. Network Security Group (NSG) for Public Subnet
resource "azurerm_network_security_group" "nsg_public" {
  name                = "nsg-public"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-NAT-Outbound"
    priority                   = 1100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  lifecycle {
    prevent_destroy = false
  }
}

# Create a Network Security Group for Private Subnet
resource "azurerm_network_security_group" "nsg_private" {
  name                = "nsg-private"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Block all inbound traffic by default (secure by design)
  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow internal communication within the Virtual Network (VNet)
  security_rule {
    name                       = "Allow-VNet-Internal"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Allow necessary outbound traffic (e.g., API requests, storage)
  security_rule {
    name                       = "Allow-API-Access"
    priority                   = 1200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "api.example.com"
  }
}

# Allow incoming SSH and HTTPS traffic through Firewall
resource "azurerm_firewall_network_rule_collection" "firewall_inbound" {
  name                = "Firewall-Inbound-Rules"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 100  # Lower number = higher priority
  action              = "Allow"

  rule {
    name                  = "Allow-SSH"
    source_addresses      = ["1.2.3.4"]  # Replace with admin's IP
    destination_addresses = ["*"]
    destination_ports     = ["22"]
    protocols             = ["TCP"]
  }

  rule {
    name                  = "Allow-HTTPS"
    source_addresses      = ["*"]
    destination_addresses = ["*"]
    destination_ports     = ["443"]
    protocols             = ["TCP"]
  }
}

# Block all other incoming traffic
resource "azurerm_firewall_network_rule_collection" "firewall_deny_all_inbound" {
  name                = "Firewall-Deny-All-Inbound"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 200
  action              = "Deny"

  rule {
    name                  = "Block-All-Traffic"
    source_addresses      = ["*"]
    destination_addresses = ["*"]
    destination_ports     = ["*"]
    protocols             = ["TCP", "UDP"]
  }
}

# 9. Key Vault

# 25. Key Vault
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

# 26. Additional Example Secret

resource "azurerm_key_vault_secret" "example_secret" {
  key_vault_id = azurerm_key_vault.key_vault.id
  name         = "example-password-${random_string.suffix.result}"
  value        = random_password.synapse_sql_password.result
}

# 27. Role Assignment for Key Vault Reader
resource "azurerm_role_assignment" "key_vault_reader" {
  principal_id         = var.service_principal_id
  role_definition_name = "Key Vault Reader"
  scope                = azurerm_key_vault.key_vault.id

  timeouts {
    create = "10m"
  }
}

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

# Synapse SQL Password Secret
resource "random_password" "synapse_sql_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric  = true
}

# Role Assignment for Databricks Admin
resource "azurerm_role_assignment" "databricks_admin" {
  scope                = azurerm_databricks_workspace.example.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.current.object_id

  depends_on = [azurerm_databricks_workspace.example]
}

# Role Assignment Contributor for Service Principal
resource "azurerm_role_assignment" "example" {
  principal_id         = var.service_principal_id
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.rg.id
}

# RBAC for Synapse
resource "azurerm_role_assignment" "synapse_rbac" {
  principal_id         = var.service_principal_id  
  role_definition_name = "Synapse Administrator"
  scope                = azurerm_synapse_workspace.synapse_workspace.id
}

# Assign 'Storage Blob Data Contributor' role to the Service Principal
resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.service_principal_id
}

# Assign 'Storage Account Contributor' role to the Service Principal
resource "azurerm_role_assignment" "storage_account_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = var.service_principal_id
}

# Назначаем Data Factory доступ к Data Lake
resource "azurerm_role_assignment" "data_factory_storage_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.example.identity[0].principal_id
}

# Назначаем Synapse доступ к Data Lake
resource "azurerm_role_assignment" "synapse_storage_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.synapse_workspace.identity[0].principal_id
}
