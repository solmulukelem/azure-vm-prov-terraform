AZURE VM PROVISIONING USING TERRAFORM :

Define the Required Providers Defines the necessary provider required for deploying resources. The azurerm provider is specified with a version to ensure compatibility with Azure services.

Configure the Azure Provider Configures the Microsoft Azure provider, enabling Terraform to interact with Azure services. It includes default features required for managing Azure resources.

Create a Resource Group Defines a resource group, which acts as a container for managing related Azure resources. The resource group is created in a specified location and tagged for identification.

Create a Virtual Network Creates a virtual network (VNet) within the resource group. This VNet allows resources to communicate securely within an isolated network.

Create a Subnet Defines a subnet within the virtual network. The subnet segments the network, allowing different Azure services to be logically grouped.

Create a Network Security Group (NSG) Deploys a Network Security Group (NSG) to control inbound and outbound traffic for network resources. The NSG is assigned to the resource group.

Create a Network Security Rule Defines a security rule within the NSG to allow or restrict specific types of traffic based on direction, protocol, and port ranges.

Associate the NSG with the Subnet Links the Network Security Group (NSG) to the previously created subnet, ensuring traffic is filtered according to the defined security rules.

Create a Public IP Address Allocates a dynamic public IP address, which can be assigned to a virtual machine or other network resources that require external access.

Create a Network Interface (NIC) Creates a Network Interface (NIC) that enables a virtual machine to communicate within the virtual network. It includes private and public IP configurations.

Generate an SSH Key Pair Creates an RSA-based SSH key pair for secure authentication when accessing virtual machines or Kubernetes clusters.


Steps for Creating an Azure Virtual Machine Using Terraform
Define the Virtual Machine Resource

The azurerm_linux_virtual_machine resource is used to create a Linux-based virtual machine.
It is assigned a name (myVM) and linked to a specified resource group (poc-rg).
The location of the VM is set based on the resource group’s location.
The VM is associated with a network interface (poc-nic) via network_interface_ids.

Specify the VM Size

The VM size is set to "Standard_DS1_v2", which defines the CPU, memory, and performance capabilities.
Configure the OS Disk

The OS disk is given a specific name (myOsDisk).
Caching is set to "ReadWrite" to optimize performance.
The storage type is set to "Premium_LRS", which provides high-performance SSD storage.

Set the OS Image Source

The VM uses an Ubuntu 22.04 LTS image provided by Canonical.
The image reference includes:
publisher = "Canonical"
offer = "0001-com-ubuntu-server-jammy"
sku = "22_04-lts-gen2"
version = "latest"
Define VM Credentials

The computer_name is set to "myvm", which is the hostname inside the VM.
The admin_username is "azureuser".
Password authentication is disabled (disable_password_authentication = true).
Configure SSH Authentication

SSH authentication is enabled using an SSH key.
The SSH key is sourced from tls_private_key.poc_ssh.public_key_openssh, ensuring secure login access for "azureuser".
