# Implementation Plan - Container Apps Terraform Deployment

## Phase 1: Project Setup & Foundation

### 1.1 Terraform Configuration Structure
- **Approach:** Separate files per resource type
- **Structure:**
  ```
  infrastructure/
  ├── variables.tf
  ├── locals.tf
  ├── providers.tf
  ├── main.tf
  ├── key_vault.tf
  ├── managed_identity.tf
  ├── container_app_environment.tf
  ├── role_assignments.tf
  ├── frontend_container_app.tf
  ├── backend_container_app.tf
  ├── outputs.tf
  └── terraform.tfvars
  ```
- **Version Constraint:** Terraform >= 1.5.7

### 1.2 File Organization
- Single shared infrastructure directory (not separate frontend/backend directories)
- All resources co-located for easier dependency management
- Use Terraform variables and locals to differentiate between frontend and backend configs

---

## Phase 2: Azure Resource Configuration

### 2.1 Resource Naming & Location
- **Region:** UK South
- **Naming Convention:** `team2-<resource-type>-<app-name>`
  - Example: `team2-kv-main`, `team2-ca-frontend`, `team2-ca-backend`
- **Resource Group:** Create or use existing

### 2.2 Existing Resources
- **ACR already exists:**
  - Frontend image: `team2-job-app-frontend`
  - Backend image: `team2-job-app-backend`
- **Action:** Reference these in Terraform (don't create via Terraform)

---

## Phase 3: Key Vault & Secrets Management

### 3.1 Key Vault Setup
- **Approach:** Single shared Key Vault for all secrets
- **No ClickOps:** Define everything in Terraform code
- **Secrets to Store:**
  - Database connection strings
  - API keys
  - Session secrets
  - Any environment-specific credentials
  
### 3.2 Secrets Population
- **Method:** Azure CLI (post-Terraform apply)
- **Process:**
  1. Terraform creates the Key Vault structure
  2. Run Azure CLI commands to populate secrets
  3. Document required secrets in a `secrets-setup.sh` script

### 3.3 Key Vault Configuration
- Enable soft delete and purge protection
- Configure access policies for managed identities
- RBAC role: `Key Vault Secrets User` for managed identities

---

## Phase 4: Managed Identity & Access Control

### 4.1 Managed Identities
- **Strategy:** One managed identity per app (frontend + backend)
  - `team2-mi-frontend`
  - `team2-mi-backend`

### 4.2 Role Assignments
**For Frontend Managed Identity:**
- `AcrPull` on ACR (to pull frontend image)
- `Key Vault Secrets User` on Key Vault (to read secrets)

**For Backend Managed Identity:**
- `AcrPull` on ACR (to pull backend image)
- `Key Vault Secrets User` on Key Vault (to read secrets)

### 4.3 Dependency Ordering
- Create managed identities first
- Create Key Vault
- Assign roles (use `depends_on` to enforce ordering)

---

## Phase 5: Container App Environment & Networking

### 5.1 Container App Environment
- **Single shared environment** for both frontend and backend
- Configure with VNet integration for internal networking
- Enable internal ingress between apps

### 5.2 Networking Configuration
- **VNet Integration:** Enable for secure internal communication
- **Ports:**
  - Frontend: 3000 (internal)
  - Backend: 8000 (internal)
- **Frontend App:** Public ingress enabled (expose to internet)
- **Backend App:** Internal/restricted ingress only (no public access)

---

## Phase 6: Container Apps Configuration

### 6.1 Frontend Container App
- **Image:** ACR reference: `team2-job-app-frontend`
- **Ingress:** 
  - Public ingress enabled
  - External access on port 80/443
  - Internal port: 3000
- **Resources:** Bare-bones (e.g., 0.25 CPU, 512Mi memory, 1 replica minimum)
- **Managed Identity:** `team2-mi-frontend`
- **Secrets:** Reference Key Vault secrets via `key_vault_secret_id`
- **Environment Variables:** Map secrets from Key Vault

### 6.2 Backend Container App
- **Image:** ACR reference: `team2-job-app-backend`
- **Ingress:**
  - Internal ingress only (from frontend)
  - Port: 8000
  - No public access
- **Resources:** Bare-bones (0.25 CPU, 512Mi memory, 1 replica minimum)
- **Managed Identity:** `team2-mi-backend`
- **Secrets:** Reference Key Vault secrets via `key_vault_secret_id`
- **Environment Variables:** Map secrets from Key Vault

### 6.3 App-to-App Communication
- Frontend → Backend: Use internal FQDN `backend.<container-app-env>.internal`
- Ensure backend is in same environment for internal DNS resolution

---

## Phase 7: CI/CD Pipeline Integration

### 7.1 GitHub Actions Workflow
- **Trigger:** After Docker images are built and pushed to ACR
- **Steps:**
  1. Checkout code
  2. Setup Terraform
  3. `terraform init` (with backend storage if configured)
  4. `terraform plan` → output to file
  5. Create PR comment with plan (optional)
  6. `terraform apply` (on merge or manual approval)

### 7.2 Job Structure
- **Two stages:**
  1. **Plan Stage:** Validate and preview changes
  2. **Apply Stage:** Deploy infrastructure (manual approval or auto on main)

### 7.3 Pipeline Location
- Add workflow in `.github/workflows/terraform.yml`
- Runs after Docker build pipeline completes

---

## Phase 8: Testing & Validation

### 8.1 Local Testing (Simplest Approach)
- `terraform init` (without backend state to save time)
- `terraform plan` to preview changes
- Review output before committing
- Use `terraform validate` to check syntax

### 8.2 State Management
- For now: Local state (no remote backend required)
- Future: Consider Azure Blob Storage for remote state

### 8.3 Validation Checklist
- [ ] Terraform syntax validates
- [ ] Plan shows expected resources
- [ ] All dependencies are ordered correctly
- [ ] Secrets are properly referenced
- [ ] Frontend is publicly accessible
- [ ] Backend is not publicly accessible

---

## Phase 9: Deployment Steps

### Step 1: Initialize Terraform
```bash
cd infrastructure/
terraform init
```

### Step 2: Plan Deployment
```bash
terraform plan -out=tfplan
```

### Step 3: Review Plan Output
- Verify all resources will be created
- Check role assignments and dependencies

### Step 4: Apply Configuration
```bash
terraform apply tfplan
```

### Step 5: Populate Secrets
```bash
# Run Azure CLI or script to add secrets to Key Vault
az keyvault secret set --vault-name team2-kv-main --name "SessionSecret" --value "your-secret-value"
# Repeat for all required secrets
```

### Step 6: Test Application
- Access frontend at public URL
- Verify frontend → backend communication works
- Check environment variables are loaded from Key Vault

---

## Phase 10: Post-Deployment Maintenance

### 10.1 Making Updates
- Modify Terraform files (e.g., image tag, replica count)
- Run `terraform plan` to preview
- Run `terraform apply` to deploy
- Test changes

### 10.2 Multi-Environment Strategy
- Create separate directories: `infrastructure/dev/`, `infrastructure/staging/`, `infrastructure/prod/`
- Or use Terraform workspaces with separate `.tfvars` files
- Test changes in dev/staging before prod

---

## Summary of Key Decisions

| Decision | Choice |
|----------|--------|
| File Organization | Separate files per resource type |
| Infrastructure Directory | Single shared directory |
| Key Vault | Single shared vault |
| Managed Identities | One per app (2 total) |
| Container App Environment | Single shared environment |
| Frontend Access | Public ingress |
| Backend Access | Internal ingress only |
| Secrets Management | Azure CLI (post-Terraform) |
| Terraform Version | >= 1.5.7 |
| Region | UK South |
| Local Testing | `terraform init`, `plan`, `validate` |
| CI/CD Stages | Plan + Apply |

---

## Next Actions

1. ✅ Create Terraform file structure
2. ✅ Write `variables.tf` with all required inputs
3. ✅ Write `key_vault.tf` for Key Vault configuration
4. ✅ Write `managed_identity.tf` for managed identities
5. ✅ Write `container_app_environment.tf` for environment setup
6. ✅ Write `role_assignments.tf` for RBAC configuration
7. ✅ Write `frontend_container_app.tf` for frontend deployment
8. ✅ Write `backend_container_app.tf` for backend deployment
9. ✅ Write `outputs.tf` for important resource references
10. ✅ Test locally with `terraform plan`
11. ✅ Set up GitHub Actions workflow
12. ✅ Deploy and test
