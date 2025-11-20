# Team2-job-app-tf

Terraform infrastructure as code for the Team2 Job Application, deploying managed identities, Key Vault, and Container App Environment on Azure.

## Overview

This Terraform configuration sets up the foundational Azure infrastructure for the Team2 Job Application, including:

- **Resource Group** - Logical container for all resources
- **Managed Identities** - Secure authentication for frontend and backend services
- **Key Vault** - Secure secret management with RBAC
- **Container App Environment** - Managed container hosting environment
- **Role Assignments** - RBAC permissions for pulling container images and accessing secrets

## Architecture

### Managed Identities

Two user-assigned managed identities are created:

1. **Backend Identity** (`id-team2-job-app-backend`)
   - ACR Pull access - can pull images from the container registry
   - Key Vault Secrets User - can read secrets from Key Vault

2. **Frontend Identity** (`id-team2-job-app-frontend`)
   - ACR Pull access - can pull images from the container registry
   - Key Vault Secrets User - can read secrets from Key Vault

### Resources

- **Key Vault** - Stores secrets with RBAC-based access control and soft delete protection
- **Container App Environment** - Managed environment for running containerized applications
- **Container Registry** - Reference to existing ACR for pulling container images

## File Structure

```
infrastructure/
├── main.tf                  # Resource group, client config, container app environment
├── key-vaults.tf           # Key Vault resource
├── managed_identities.tf    # Managed identities and role assignments
├── providers.tf            # Terraform and provider configuration
├── variables.tf            # Variable definitions
├── outputs.tf              # Output values
├── environments/
│   └── dev.tfvars         # Development environment variables
```

## Prerequisites

- Terraform >= 1.0
- Azure CLI authenticated
- Access to Azure subscription
- Existing Azure Container Registry

## Usage

### Initialize Terraform

```bash
cd infrastructure
terraform init
```

### Plan Changes

```bash
terraform plan -var-file="environments/dev.tfvars"
```

### Apply Configuration

```bash
terraform apply -var-file="environments/dev.tfvars"
```

## Variables

Key variables (see `variables.tf` for full list):

- `resource_group_name` - Name of the resource group (default: `team2-job-app-shared-rg`)
- `location` - Azure region (default: `UK South`)
- `container_registry_name` - Name of existing ACR (default: `aiacademy25`)
- `acr_resource_group` - Resource group containing ACR (default: `container-registry`)
- `key_vault_name` - Name of Key Vault to create (default: `team2-job-app-keyvault`)
- `container_app_environment_name` - Container App Environment name (required)
- `environment` - Deployment environment (default: `dev`)
- `tags` - Tags to apply to resources (default: `{}`)

## Outputs

The configuration exports:

- `identities` - Map of managed identities with their IDs, principal IDs, and client IDs
- `resource_group` - Resource group ID and name
- `key_vault_name` - Name of the created Key Vault
- `key_vault_uri` - URI of the Key Vault
- `container_app_environment_id` - ID of the Container App Environment

## Security Notes

- Key Vault has RBAC authorization enabled (not legacy access policies)
- Soft delete protection is enabled on Key Vault
- Managed identities provide secure, passwordless authentication
- All access is controlled via Azure RBAC role assignments

## Backend State

Terraform state is stored in Azure Storage Account:
- Storage Account: `aistatemgmt`
- Container: `terraform-tfstate-ai`
- State File: `team2-job-app-infrastructure.dev.tfstate`
