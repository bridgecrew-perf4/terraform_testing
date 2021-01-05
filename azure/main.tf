terraform {
  required_providers { //Aqui é só para dizer o que vai ser usado!!!
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.39"
    }
  }
  required_version = ">= 0.14"
}

/* Azure now */

provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  //version = "=2.20.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "testing1" {
  name     = "testing1_resource"
  location = "West Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "testing1" {
  name                = "testing1_network"
  resource_group_name = azurerm_resource_group.testing1.name
  location            = azurerm_resource_group.testing1.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "testing1" {
  name                 = "testing1_mySubnet"
  resource_group_name  = azurerm_resource_group.testing1.name
  virtual_network_name = azurerm_virtual_network.testing1.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_public_ip" "testing1" {
  name                = "testing1_publicIP"
  location            = azurerm_resource_group.testing1.location
  resource_group_name = azurerm_resource_group.testing1.name
  allocation_method   = "Dynamic"

  /* tags = {
        environment = "Terraform Demo"
    } */
}


resource "azurerm_network_security_group" "testing1" {
  name                = "testing1_myNetworkSecurityGroup"
  location            = azurerm_resource_group.testing1.location
  resource_group_name = azurerm_resource_group.testing1.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  /* tags = {
        environment = "Terraform Demo"
    } */
}


/* output "azure_ip" {
  value = azurerm_public_ip.ip_address
} */


resource "azurerm_network_interface" "testing1" {
  name                = "testing1_nwInterface"
  location            = azurerm_resource_group.testing1.location
  resource_group_name = azurerm_resource_group.testing1.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.testing1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.testing1.id
  }

  /* tags = {
        environment = "Terraform Demo"
    } */
}

resource "azurerm_network_watcher" "testing1" { //to avoid automatic creation
  name                = "testing1_nwatcher"
  location            = azurerm_resource_group.testing1.location
  resource_group_name = azurerm_resource_group.testing1.name
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "testing1" {
  network_interface_id      = azurerm_network_interface.testing1.id
  network_security_group_id = azurerm_network_security_group.testing1.id
}


resource "tls_private_key" "testing1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "tls_private_key" { value = tls_private_key.testing1.private_key_pem }

resource "vault_mount" "example" {
  type = "ssh"
}

resource "vault_ssh_secret_backend_ca" "foo" {
  private_key = tls_private_key.testing1.private_key_pem
}

resource "azurerm_linux_virtual_machine" "testing1" {
  name                  = "testing1_vm"
  location              = azurerm_resource_group.testing1.location
  resource_group_name   = azurerm_resource_group.testing1.name
  network_interface_ids = [azurerm_network_interface.testing1.id]
  size                  = "Standard_B1S"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.testing1.public_key_openssh
  }
  /* 
    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.testing1.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
    } */
}

output "tls_public_key" { value = tls_private_key.testing1.public_key_openssh }


/* output "address" {
  value = azurerm_resource_group.testing1.address_space
} */
