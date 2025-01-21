
# Azure Infrastructure Project: Comprehensive Deployment Using Terraform

## Overview
This project demonstrates the creation of a fully functional infrastructure in Azure using Terraform, covering key aspects of cloud architecture, network administration, and data engineering. It combines knowledge from three Azure certifications:
- **AZ-900**: Fundamental Azure cloud concepts.
- **AZ-104**: Azure infrastructure and network administration.
- **DP-203**: Data engineering, storage, and analytics.

---

## Key Features

### 1. Infrastructure Deployment
- **Virtual Network (VNet):**
  - Public subnets for NAT Gateway and Bastion.
  - Private subnets for Virtual Machines and data storage.
- **Security and Access:**
  - NAT Gateway for internet access from private subnets.
  - Azure Bastion for secure RDP/SSH access to Virtual Machines.
  - Network Security Groups (NSG) for traffic management.
- **Virtual Machines:**
  - Creation and configuration of VMs with automated backup.

### 2. Data Storage and Management
- **Storage Accounts:**
  - Blob Storage for raw data.
  - Data Lake Storage Gen2 for structured data management.
- **Access Control:**
  - Role-Based Access Control (RBAC) and ACLs for secure data access.
- **Data Lifecycle:**
  - Automated policies for data retention and archiving.

### 3. ETL Processes and Data Processing
- **Azure Data Factory (ADF):**
  - ETL pipelines for data movement and transformation.
- **Azure Databricks:**
  - Big data processing using Spark-based workflows.

### 4. Data Analytics and Visualization
- **Azure Synapse Analytics:**
  - Analytical data warehouse integration with Data Lake Storage.
- **Power BI:**
  - Visualization of analytics and insights.

### 5. Automation and Scalability
- **Terraform Automation:**
  - Deployment and management of all resources.
- **Auto-scaling:**
  - Dynamic scaling of Virtual Machines for optimized performance.

---

## Project Deliverables
- Fully automated Azure infrastructure for networking, storage, and data analytics.
- ETL pipelines leveraging Azure Data Factory and Databricks.
- Analytics-ready data warehouse integrated with Power BI for visualization.
- Terraform scripts for infrastructure deployment and management.

---

## Deployment Order

To ensure successful deployment, resources must be created in the following order. Dependencies between resources are clearly stated:

### Deployment Order with Dependencies

  1.	azurerm_resource_group.rg - Create the resource group.
	2.	azurerm_virtual_network.vnet - Create the virtual network.
	3.	azurerm_subnet.public - Create the public subnet.
	4.	azurerm_subnet.private - Create the private subnet.
	5.	azurerm_subnet.databricks - Create the Databricks subnet.
	6.	azurerm_subnet.bastion_subnet - Create the Bastion subnet.
	7.	azurerm_storage_account.storage - Create the storage account.
	8.	azurerm_storage_container.data_container - Create the storage container.
	9.	azurerm_storage_data_lake_gen2_filesystem.data_lake_filesystem - Create the Data Lake Gen2 filesystem.
	10.	azurerm_network_security_group.nsg_public - Create the public network security group.
	11.	azurerm_network_interface.public_nic - Create the public NIC.
	12.	azurerm_network_interface.private_nic - Create the private NIC.
	13.	azurerm_public_ip.public_vm_ip - Create the public IP for the VM.
	14.	azurerm_public_ip.bastion_ip - Create the public IP for Bastion.
	15.	azurerm_public_ip.nat_gateway_ip - Create the public IP for NAT Gateway.
	16.	azurerm_nat_gateway.nat_gateway - Create the NAT Gateway.
	17.	azurerm_subnet_nat_gateway_association.private_nat_assoc - Associate NAT Gateway with the private subnet.
	18.	azurerm_subnet_nat_gateway_association.databricks_nat_assoc - Associate NAT Gateway with the Databricks subnet.
	19.	azurerm_recovery_services_vault.backup_vault - Create the Recovery Services Vault.
	20.	azurerm_backup_policy_vm.vm_backup_policy - Create the VM backup policy.
	21.	azurerm_backup_protected_vm.protected_vm_private - Protect the private VM with the backup policy.
	22.	azurerm_backup_protected_vm.protected_vm_public - Protect the public VM with the backup policy.
	23.	azurerm_key_vault.key_vault - Create the Key Vault.
	24.	azurerm_bastion_host.bastion - Create the Bastion Host.
	25.	azurerm_linux_virtual_machine.public_vm - Create the public Linux VM.
	26.	azurerm_linux_virtual_machine.private_vm - Create the private Linux VM.
	27.	azurerm_synapse_workspace.synapse_workspace - Create the Synapse Workspace.
	28.	azurerm_synapse_sql_pool.sql_pool - Create the Synapse SQL Pool.
	29.	azurerm_data_factory.example - Create the Data Factory instance.
	30.	azurerm_data_factory_pipeline.etl_pipeline - Create the ETL pipeline in Data Factory.
	31.	azurerm_data_factory_dataset_azure_blob.example - Create the Azure Blob dataset.
	32.	azurerm_data_factory_dataset_sql_server_table.synapse_dataset - Create the Synapse dataset.
	33.	azurerm_data_factory_dataset_sql_server_table.analytics_synapse_dataset - Create the Analytics Synapse dataset.
	34.	azurerm_data_factory_linked_service_azure_blob_storage.blob_service_link - Create the Azure Blob linked service.
	35.	azurerm_data_factory_linked_service_sql_server.example - Create the SQL Server linked service.
	36.	azurerm_data_factory_linked_service_synapse.synapse_link - Create the Synapse linked service.
	37.	azurerm_databricks_workspace.example - Create the Databricks Workspace.
	38.	azurerm_storage_blob.data_blob - Upload the test data blob.
	39.	azurerm_role_assignment.key_vault_reader - Assign the Key Vault Reader role.
	40.	azurerm_role_assignment.databricks_admin - Assign the Databricks Admin role.
	41.	null_resource.add_principal_to_admins - Add the principal to admins (custom script).
	42.	null_resource.create_databricks_cluster - Create the Databricks Cluster (custom script).
	43.	random_password.synapse_sql_password - Generate the Synapse SQL password.
	44.	random_string.suffix - Generate a random string for resource suffixes.
	45.	random_string.suffix_analytics - Generate a random string for Analytics suffixes.
	46.	random_string.suffix_processing - Generate a random string for Processing suffixes.
 

---

## How to Use
1. **Setup Requirements:**
   - Install Terraform and Azure CLI.
   - Configure an active Azure subscription.
2. **Deployment:**
   - Use the Terraform scripts provided to deploy the infrastructure in the specified order.
3. **Commands:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
---

## Technologies Used
- **Azure Services:** Virtual Network, Storage Accounts, Data Factory, Databricks, Synapse Analytics, Azure Bastion, NAT Gateway, Azure Monitor, and Azure Backup.
- **Automation:** Terraform for Infrastructure as Code (IaC).
- **Analytics Tools:** Power BI for visualization and reporting.

---

## License
This project is licensed under the MIT License. Feel free to use and adapt it for your needs.