
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

#### From `main.tf`
1. `azurerm_resource_group 'rg'`  
2. `azurerm_virtual_network 'vnet'`  
3. `azurerm_subnet 'public'`  
4. `azurerm_subnet 'private'`  
5. `azurerm_subnet 'databricks'`  
6. `azurerm_subnet 'bastion_subnet'`  
7. `azurerm_public_ip 'nat_gateway_ip'`  
8. `azurerm_public_ip 'bastion_ip'`  
9. `azurerm_public_ip 'public_vm_ip'`  
10. `azurerm_nat_gateway 'nat_gateway'`  
    • **depends_on**: `azurerm_public_ip 'nat_gateway_ip'`  
11. `azurerm_nat_gateway_public_ip_association 'nat_gateway_assoc'`  
    • **depends_on**: `azurerm_nat_gateway 'nat_gateway'`  
12. `azurerm_subnet_nat_gateway_association 'private_nat_assoc'`  
    • **depends_on**: `azurerm_nat_gateway 'nat_gateway'`  
13. `azurerm_subnet_nat_gateway_association 'databricks_nat_assoc'`  
    • **depends_on**: `azurerm_nat_gateway 'nat_gateway'`  

#### From `storage.tf`
14. `azurerm_storage_account 'storage'`  
15. `azurerm_storage_data_lake_gen2_filesystem 'data_lake_filesystem'`  
    • **depends_on**: `azurerm_storage_account 'storage'`  
16. `azurerm_storage_container 'data_container'`  
    • **depends_on**: `azurerm_storage_account 'storage'`  
17. `azurerm_storage_blob 'data_blob'`  
    • **depends_on**: `azurerm_storage_container 'data_container'`  

#### From `security.tf`
18. `azurerm_key_vault 'key_vault'`  
19. `azurerm_key_vault_access_policy 'terraform_access'`  
    • **depends_on**: `azurerm_key_vault 'key_vault'`  
20. `azurerm_key_vault_secret 'synapse_sql_password'`  
    • **depends_on**: `azurerm_key_vault 'key_vault'`  
21. `azurerm_key_vault_secret 'example_secret'`  
    • **depends_on**: `azurerm_key_vault 'key_vault'`  

#### Back to `main.tf`
22. `azurerm_linux_virtual_machine 'public_vm'`  
    • **depends_on**: `azurerm_subnet_nat_gateway_association 'private_nat_assoc'`  
23. `azurerm_linux_virtual_machine 'private_vm'`  
    • **depends_on**: `azurerm_subnet_nat_gateway_association 'private_nat_assoc'`  

#### From `data_processing.tf`
24. `azurerm_data_factory 'example'`  
25. `azurerm_data_factory_pipeline 'etl_pipeline'`
    • **depends_on**: `azurerm_data_factory_dataset_azure_blob 'example', azurerm_data_factory_dataset_sql_server_table 'synapse_dataset'`
26. `azurerm_data_factory_pipeline 'databricks_etl'`  
    • **depends_on**: `azurerm_data_factory_dataset_azure_blob 'example', azurerm_data_factory_dataset_sql_server_table 'synapse_dataset'`  
27. `azurerm_data_factory_linked_service_azure_blob_storage 'blob_service_link'`  
    • **depends_on**: `azurerm_storage_account 'storage'`  
28. `azurerm_data_factory_linked_service_azure_blob_storage 'data_lake_service_link'`  
    • **depends_on**: `azurerm_storage_account 'storage'`  
29. `azurerm_data_factory_dataset_sql_server_table 'synapse_dataset'`  
    • **depends_on**: `azurerm_data_factory 'example'`  

#### From `analytics.tf`
33. `azurerm_synapse_workspace 'synapse_workspace'`  
34. `azurerm_synapse_sql_pool 'sql_pool'`  
    • **depends_on**: `azurerm_synapse_workspace 'synapse_workspace'`  
35. `azurerm_role_assignment 'synapse_rbac'`  
    • **depends_on**: `azurerm_synapse_workspace 'synapse_workspace'`  

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