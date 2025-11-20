# User-assigned managed identity for container app
resource "azurerm_user_assigned_identity" "frontend" {
  name                = var.managed_identity_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# Allow managed identity to read secrets from Key Vault
resource "azurerm_role_assignment" "managed_identity_kv_secrets" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.frontend.principal_id
}
