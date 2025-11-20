# Outputs
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

output "managed_identity_id" {
  description = "The ID of the managed identity"
  value       = azurerm_user_assigned_identity.frontend.id
}

output "managed_identity_principal_id" {
  description = "The principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.frontend.principal_id
}
