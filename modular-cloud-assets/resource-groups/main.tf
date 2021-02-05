provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "myterrarg" {
  name     = "${var.prefix}-rg"
  location = var.location
}