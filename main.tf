terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.107.0"
      #version = "=3.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider (required) - Test
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "poc-rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
  tags     = "${var.tags}"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "poc-vn" {
  name                = "${var.azurerm_virtual_network}"
  resource_group_name = azurerm_resource_group.poc-rg.name
  location            = "${var.location}"
  address_space       = ["10.0.0.0/16"]
}

# Create a subnets within the resource group and Virtual Network
resource "azurerm_subnet" "poc-subnet" {
  name                 = "${var.azurerm_subnet}"
  resource_group_name  = azurerm_resource_group.poc-rg.name
  virtual_network_name = azurerm_virtual_network.poc-vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "poc-nsg" {
  name                = "${var.azurerm_network_security_group}"
  location            = "${var.location}"
  resource_group_name = azurerm_resource_group.poc-rg.name

  tags = {
    environment = "poc"
  }
}

resource "azurerm_network_security_rule" "poc-nsr-ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.poc-rg.name
  network_security_group_name = azurerm_network_security_group.poc-nsg.name
}

resource "azurerm_network_security_rule" "poc-nsr-icmp" {
  name                        = "Allow-ICMP"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.poc-rg.name
  network_security_group_name = azurerm_network_security_group.poc-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "poc-sga" {
  subnet_id                 = azurerm_subnet.poc-subnet.id
  network_security_group_id = azurerm_network_security_group.poc-nsg.id
}


resource "azurerm_public_ip" "poc-ip" {
  name                = "sol-poc-ip"
  resource_group_name = azurerm_resource_group.poc-rg.name
  location            = "${var.location}"
  allocation_method   = "Dynamic"

  tags = {
    environment = "poc"
  }
}

resource "azurerm_network_interface" "poc-nic" {
  name                = "sol-poc-nic"
  location            = "${var.location}"
  resource_group_name = azurerm_resource_group.poc-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.poc-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.poc-ip.id
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "poc_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "myVM"
  location              = azurerm_resource_group.poc-rg.location
  resource_group_name   = azurerm_resource_group.poc-rg.name
  network_interface_ids = [azurerm_network_interface.poc-nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = "azure12s$"
  disable_password_authentication = false

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.poc_ssh.public_key_openssh
  }

}
