provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "myterrarg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "myterravnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.myterrarg.location
  resource_group_name = azurerm_resource_group.myterrarg.name
}

resource "azurerm_subnet" "myterrasubnet" {
  name                 = "MySubnet"
  resource_group_name  = azurerm_resource_group.myterrarg.name
  virtual_network_name = azurerm_virtual_network.myterravnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "myterrapublicip" {
  name                = "${var.prefix}-publicIP"
  location            = azurerm_resource_group.myterrarg.location
  resource_group_name = azurerm_resource_group.myterrarg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "myterranic" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.myterrarg.name
  location            = azurerm_resource_group.myterrarg.location

  ip_configuration {
    name                          = "myNicConfig"
    subnet_id                     = azurerm_subnet.myterrasubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterrapublicip.id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.myterrarg.name
  location                        = azurerm_resource_group.myterrarg.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.myterranic.id,
  ]

  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}