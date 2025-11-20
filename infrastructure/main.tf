resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Data source to get current user info
data "azurerm_client_config" "current" {}

# Data source for ACR (existing resource)
data "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = var.acr_resource_group
}

# Azure Key Vault
resource "azurerm_key_vault" "kv" {
  name                     = var.key_vault_name
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true

  # Enable RBAC authorization instead of access policies
  enable_rbac_authorization = true

  tags = var.tags
}

# Container App Environment
resource "azurerm_container_app_environment" "env" {
  name                = var.container_app_environment_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}