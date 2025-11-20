variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to create"
  default     = "team2-job-app-shared-rg"
}

variable "location" {
  type        = string
  description = "Azure location for resources"
  default     = "UK South"
}

variable "container_registry_name" {
  type        = string
  description = "Name of the Azure Container Registry"
  default     = "aiacademy25"
}

variable "acr_resource_group" {
  type        = string
  description = "Resource group containing Azure Container Registry"
  default     = "container-registry"
}

variable "key_vault_name" {
  type        = string
  description = "Name of the Azure Key Vault"
  default     = "team2-job-app-keyvault"
}

variable "container_app_environment_name" {
  type        = string
  description = "Name of the Container App Environment"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, prod)"
  default     = "dev"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
