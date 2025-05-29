data "azurerm_client_config" "current" {}

resource "random_string" "resource-code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_role_assignment" "blob-data-contributor" {
  scope                = azurerm_storage_account.web.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project}-${resource.random_string.resource-code.result}"
  location = var.az-region # list location = az account list-locations -o table
  tags     = var.tags
}

resource "azurerm_storage_account" "web" {
  name                            = "sastaticwebsite${resource.random_string.resource-code.result}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  access_tier                     = "Hot"
  shared_access_key_enabled       = true
  default_to_oauth_authentication = true
  account_kind                    = "StorageV2"

  infrastructure_encryption_enabled = true
  routing {
    publish_microsoft_endpoints = true
  }

  tags = var.tags
}

resource "azurerm_storage_account_static_website" "test" {
  storage_account_id = azurerm_storage_account.web.id
  error_404_document = "404.html"
  index_document     = "index.html"
}

resource "azurerm_storage_blob" "index" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.web.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${path.module}/src/index.html"
  content_type           = "text/html"

  depends_on = [azurerm_storage_account.web]
}

resource "azurerm_storage_blob" "error" {
  name                   = "404.html"
  storage_account_name   = azurerm_storage_account.web.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${path.module}/src/404.html"
  content_type           = "text/html"

  depends_on = [azurerm_storage_account.web]
}