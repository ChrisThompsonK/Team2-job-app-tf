variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to create"
  default     = "team2-fs-test-rg-dev-rg"
}

variable "location" {
  type        = string
  description = "Azure location for resources"
  default     = "UK South"
}
variable "key_vault_name" {
  type        = string
  description = "Name of the Azure Key Vault"
}

variable "container_app_environment_name" {
  type        = string
  description = "Name of the Container App Environment"
}

variable "managed_identity_name" {
  type        = string
  description = "Name of the user-assigned managed identity"
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to resources"
  default     = {}
}