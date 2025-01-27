
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

  1.	azurerm_resource_group.rg
	2.	azurerm_virtual_network.vnet
	3.	azurerm_subnet.bastion_subnet
	4.	azurerm_subnet.private
	5.	azurerm_subnet.public
	6.	azurerm_subnet.databricks
	7.	azurerm_subnet.firewall_subnet
	8.	azurerm_subnet.gateway_subnet
	9.	azurerm_nat_gateway.nat_gateway
	10.	azurerm_nat_gateway_public_ip_association.nat_gateway_assoc
	11.	azurerm_public_ip.bastion_ip
	12.	azurerm_public_ip.nat_gateway_ip
	13.	azurerm_public_ip.public_vm_ip
	14.	azurerm_public_ip.firewall_ip
	15.	azurerm_public_ip.vpn_gateway_ip
	16.	azurerm_network_interface.private_nic
	17.	azurerm_network_interface.public_nic
	18.	azurerm_network_security_group.nsg_public
	19.	azurerm_subnet_nat_gateway_association.private_nat_assoc
	20.	azurerm_subnet_nat_gateway_association.databricks_nat_assoc
	21.	azurerm_subnet_network_security_group_association.nsg_public_assoc
	22.	azurerm_route_table.firewall_route_table
	23.	azurerm_subnet_route_table_association.firewall_route_assoc[“databricks”]
	24.	azurerm_subnet_route_table_association.firewall_route_assoc[“private”]
	25.	azurerm_subnet_route_table_association.firewall_route_assoc[“public”]
	26.	azurerm_firewall.firewall
	27.	azurerm_bastion_host.bastion
	28.	azurerm_key_vault.key_vault
	29.	azurerm_key_vault_secret.example_secret
	30.	azurerm_role_assignment.key_vault_reader
	31.	azurerm_storage_account.storage
	32.	azurerm_storage_account_network_rules.network_rules
	33.	azurerm_storage_container.data_container
	34.	azurerm_storage_blob.data_blob
	35.	azurerm_storage_data_lake_gen2_filesystem.data_lake_filesystem
	36.	azurerm_private_dns_zone.dns_zone
	37.	azurerm_private_dns_zone_virtual_network_link.dns_link
	38.	azurerm_private_endpoint.storage_private_link
	39.	azurerm_data_factory.example
	40.	azurerm_data_factory_pipeline.etl_pipeline
	41.	azurerm_data_factory_pipeline.databricks_etl
	42.	azurerm_data_factory_dataset_azure_blob.example
	43.	azurerm_data_factory_dataset_sql_server_table.analytics_synapse_dataset
	44.	azurerm_data_factory_dataset_sql_server_table.synapse_dataset
	45.	azurerm_data_factory_linked_service_azure_blob_storage.blob_service_link
	46.	azurerm_data_factory_linked_service_azure_blob_storage.data_lake_service_link
	47.	azurerm_data_factory_linked_service_sql_server.example
	48.	azurerm_data_factory_linked_service_synapse.synapse_link
	49.	azurerm_databricks_workspace.example
	50.	azurerm_synapse_workspace.synapse_workspace
	51.	azurerm_synapse_sql_pool.sql_pool
	52.	azurerm_synapse_private_link_hub.private_link
	53.	azurerm_mssql_server.sql_server
	54.	azurerm_mssql_server_transparent_data_encryption.data_masking
	55.	azurerm_monitor_action_group.email_alerts
	56.	azurerm_monitor_diagnostic_setting.data_factory_logs
	57.	azurerm_monitor_diagnostic_setting.databricks_logs
	58.	azurerm_monitor_diagnostic_setting.vnet_logs
	59.	azurerm_monitor_metric_alert.private_vm_cpu_alert
	60.	azurerm_monitor_metric_alert.public_vm_cpu_alert
	61.	azurerm_log_analytics_workspace.logs
	62.	azurerm_backup_policy_vm.vm_backup_policy
	63.	azurerm_backup_protected_vm.protected_vm_private
	64.	azurerm_backup_protected_vm.protected_vm_public
	65.	azurerm_recovery_services_vault.backup_vault
	66.	azurerm_linux_virtual_machine.private_vm
	67.	azurerm_linux_virtual_machine.public_vm
	68.	azurerm_role_assignment.storage_account_contributor
	69.	azurerm_role_assignment.storage_blob_data_contributor
	70.	azurerm_role_assignment.synapse_rbac
	71.	azurerm_role_assignment.example
	72.	azurerm_role_assignment.databricks_admin
	73.	azurerm_policy_definition.encryption_policy
	74.	random_password.synapse_sql_password
	75.	random_string.suffix
	76.	random_string.suffix_analytics
	77.	random_string.suffix_processing
	78.	null_resource.add_principal_to_admins
	79.	null_resource.create_databricks_cluster
	80.	null_resource.enable_public_access
 

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