resource "azurerm_virtual_network" "this" {
  name = "main"
  address_space = ["10.0.0.0/16"]
  location = var.location
  resource_group_name = var.resource_group_name

  tags = {
    env = var.env
  }
}
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  address_prefixes     = ["10.0.0.0/19"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  address_prefixes     = ["10.0.32.0/19"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
}