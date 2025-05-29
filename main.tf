data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project}-${resource.random_string.resource-code.result}"
  location = var.az-region # list location = az account list-locations -o table
  tags     = var.tags
}