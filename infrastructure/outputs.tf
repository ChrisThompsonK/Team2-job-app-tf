output "identities" {
  description = "Managed identities keyed by name (backend, frontend)"
  value = {
    for k, v in azurerm_user_assigned_identity.identity : k => {
      id           = v.id
      principal_id = v.principal_id
      client_id    = v.client_id
    }
  }
}

output "resource_group" {
  description = "Resource group details"
  value = {
    id   = azurerm_resource_group.rg.id
    name = azurerm_resource_group.rg.name
  }
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

output "container_app_environment_id" {
  description = "The ID of the Container App Environment"
  value       = azurerm_container_app_environment.env.id
}
