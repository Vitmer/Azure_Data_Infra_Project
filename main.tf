provider "azurerm" {
  features {}
  skip_provider_registration = true

  client_id       = var.rbac_principal_id
  client_secret   = var.service_principal_key
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

provider "databricks" {
  host  = "https://westeurope.azuredatabricks.net"
}

terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.11.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.66.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  lifecycle {
  prevent_destroy = true
}
}

# 2. Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "VNet-Project"   
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  lifecycle {
    prevent_destroy = true
  }
}

# 3. Public Subnet
resource "azurerm_subnet" "public" {
  name                 = "Public-Subnet"  # Старое имя Public Subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  lifecycle {
    ignore_changes = [address_prefixes]
  }
}

# 4. Private Subnet
resource "azurerm_subnet" "private" {
  name                 = "Private-Subnet"  
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  lifecycle {
    ignore_changes = [address_prefixes]
  }
}

# 5. Databricks Subnet
resource "azurerm_subnet" "databricks" {
  depends_on = [azurerm_virtual_network.vnet]
  name                 = "Databricks-Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]

  lifecycle {
  ignore_changes = [
    address_prefixes
  ]
  }
}

# 6. Azure Bastion Subnet
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]

  lifecycle {
    prevent_destroy = true
  }
}

# 7. Public IP for NAT Gateway
resource "azurerm_public_ip" "nat_gateway_ip" {
  name                = "nat-gateway-ip"  
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
  prevent_destroy = true
  }
}

# 8. Public IP for Bastion
resource "azurerm_public_ip" "bastion_ip" {
  name                = "bastion-ip"   # Старое имя Bastion IP
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
  prevent_destroy = true
}
}

# 9. Public IP for VM
resource "azurerm_public_ip" "public_vm_ip" {
  name                = "public-vm-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    prevent_destroy = true
  }
}

# 10. NAT Gateway
resource "azurerm_nat_gateway" "nat_gateway" {
  name                = "nat-gateway"   
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "Standard"

  depends_on = [azurerm_public_ip.nat_gateway_ip]
}

# 11. Associate NAT Gateway with Public IP
resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.nat_gateway_ip.id

  depends_on = [azurerm_nat_gateway.nat_gateway]
}

# 12. Attach NAT Gateway to Private Subnet
resource "azurerm_subnet_nat_gateway_association" "private_nat_assoc" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id

  depends_on = [azurerm_nat_gateway.nat_gateway]
}

# 13. Attach NAT Gateway to Databricks Subnet
resource "azurerm_subnet_nat_gateway_association" "databricks_nat_assoc" {
  subnet_id      = azurerm_subnet.databricks.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id

  depends_on = [azurerm_nat_gateway.nat_gateway]
}

# 22. Virtual Machine in Public Subnet
resource "azurerm_linux_virtual_machine" "public_vm" {
  name                = "vm-public"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  
  depends_on = [azurerm_subnet_nat_gateway_association.private_nat_assoc]

  network_interface_ids = [
    azurerm_network_interface.public_nic.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# 23. Virtual Machine in Private Subnet (accessed via Bastion)
resource "azurerm_linux_virtual_machine" "private_vm" {
  name                = "vm-private"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"

  depends_on = [azurerm_subnet_nat_gateway_association.private_nat_assoc]

  network_interface_ids = [
    azurerm_network_interface.private_nic.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

 lifecycle {
    prevent_destroy = true
  }
}

# 41. Azure Bastion Host
resource "azurerm_bastion_host" "bastion" {
  name                = "bastion-host"  # Старое имя Bastion Host
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"

  depends_on = [azurerm_public_ip.bastion_ip]

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }

  lifecycle {
    prevent_destroy = true
  }
}

# 42. Network Security Group (NSG) for Public Subnet
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
    prevent_destroy = true
  }
}

# 43. Associate NSG with Public Subnet
resource "azurerm_subnet_network_security_group_association" "nsg_public_assoc" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.nsg_public.id

  depends_on =[azurerm_network_security_group.nsg_public]

  lifecycle {
    prevent_destroy = true
  }
}

# 44. Public Network Interface
resource "azurerm_network_interface" "public_nic" {
  name                = "public-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_subnet.public]

  ip_configuration {
    name                          = "public-ip-config"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_vm_ip.id
  }

  lifecycle {
    prevent_destroy = true
  }
}

# 45. Private Network Interface
resource "azurerm_network_interface" "private_nic" {
  name                = "private-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [azurerm_subnet.private]

  ip_configuration {
    name                          = "private-ip-config"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# 46. Backup Vault for Automatic Backups
resource "azurerm_recovery_services_vault" "backup_vault" {
  name                = "backup-vault"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku = "Standard"
}

# 47. Backup Policy for VMs
resource "azurerm_backup_policy_vm" "vm_backup_policy" {
  name                = "daily-backup-policy"
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.backup_vault.name

  depends_on = [azurerm_recovery_services_vault.backup_vault]

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}

# 48. Protect Public VM with Backup
resource "azurerm_backup_protected_vm" "protected_vm_public" {
  resource_group_name       = azurerm_resource_group.rg.name
  recovery_vault_name       = azurerm_recovery_services_vault.backup_vault.name
  source_vm_id              = azurerm_linux_virtual_machine.public_vm.id
  backup_policy_id          = azurerm_backup_policy_vm.vm_backup_policy.id

  depends_on = [azurerm_backup_policy_vm.vm_backup_policy]
}

# 49. Protect Private VM with Backup
resource "azurerm_backup_protected_vm" "protected_vm_private" {
  resource_group_name       = azurerm_resource_group.rg.name
  recovery_vault_name       = azurerm_recovery_services_vault.backup_vault.name
  source_vm_id              = azurerm_linux_virtual_machine.private_vm.id
  backup_policy_id          = azurerm_backup_policy_vm.vm_backup_policy.id

  depends_on = [azurerm_backup_policy_vm.vm_backup_policy]
}

# 50. Enable public network access for the Databricks workspace
resource "null_resource" "enable_public_access" {
  provisioner "local-exec" {
    command = <<EOT
      az databricks workspace update --resource-group ${var.resource_group_name} \
        --name ${var.databricks_workspace_name} --public-network-access Enabled
    EOT
  }

  depends_on = [azurerm_databricks_workspace.example]
}