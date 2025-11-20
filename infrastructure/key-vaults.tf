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
