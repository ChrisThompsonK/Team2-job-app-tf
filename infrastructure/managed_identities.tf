locals {
  identities = {
    backend  = "Backend"
    frontend = "Frontend"
  }
}

# User Assigned Managed Identities
resource "azurerm_user_assigned_identity" "identity" {
  for_each = local.identities

  name                = "id-team2-job-app-${each.key}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = merge(
    var.tags,
    {
      Component   = each.value
      Environment = var.environment
      Project     = "Team2-Job-App"
    }
  )
}

# Role Assignments: ACR Pull Access
resource "azurerm_role_assignment" "acr_pull" {
  for_each = local.identities

  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.identity[each.key].principal_id
}

# Role Assignments: Key Vault Secrets User
resource "azurerm_role_assignment" "keyvault_access" {
  for_each = local.identities

  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.identity[each.key].principal_id
}
