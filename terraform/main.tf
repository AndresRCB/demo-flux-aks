resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

module "public_aks_cluster" {
  source = "github.com/AndresRCB/aks-public-cluster"

  resource_group_name = azurerm_resource_group.main.name
  depends_on = [
    azurerm_resource_group.main
  ]
}
