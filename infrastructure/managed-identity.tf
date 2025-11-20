# User-assigned managed identity for container app
resource "azurerm_user_assigned_identity" "frontend" {
  name                = var.managed_identity_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}
