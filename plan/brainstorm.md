# Implementation Brainstorm - Container Apps Terraform Deployment

## Project Structure & Organization

1. How should we organize the Terraform files (separate files per resource type vs. monolithic)? - i think seperate files per resource type will work best here
2. Do we need separate directories for frontend and backend configurations, or one shared infrastructure directory? - Idk
3. Should we version our Terraform code with tags/releases in the repo? - minimum version of 1.5.7

## Azure Resource Strategy

4. What Azure region should we target for Container Apps deployment? - UK South
5. What naming convention should we use for all resources (key vault, managed identity, container apps, etc.)? - i think i need to use azure key vaults (no clickops)
6. Do we already have an ACR (Azure Container Registry) created, or do we need to create it via Terraform? - i have it created frontend is called team2-job-app-frontend and the backend is called team2-job-app-backend

## Key Vault & Secrets Management

7. What specific secrets will the frontend and backend applications need (e.g., API keys, connection strings, session secrets)? - all near enough
8. Should we create separate Key Vaults for frontend and backend, or use one shared Key Vault? - all together
9. How will secrets be populated initially—through Azure Portal, Azure CLI, or a separate script? - azure cli

## Managed Identity & Access Control

10. Should we create one managed identity per app or a shared identity for both frontend and backend? - one for each
11. What specific roles/permissions does the managed identity need for ACR and Key Vault access? 

## Container App Configuration

12. What are the resource requirements (CPU, memory, replica counts) for frontend and backend apps? - bare-bones nothing too overkill
13. What port does the backend service listen on, and what port should the frontend use internally? - i think frontend runs on 3000 and the backend on 8000
14. Do the frontend and backend apps need to communicate internally, and if so, how (direct calls, service discovery)? - idk

## Networking & Security

15. Should we place both apps in the same Container App Environment or separate environments? - same environment
16. Do we need internal networking between frontend and backend (VNet integration, internal ingress)? - vnet integration
17. Should we use Application Gateway or another mechanism for public routing to the frontend? - whatever is simplest

## CI/CD Pipeline Integration

18. Where in the GitHub Actions pipeline should Terraform run (after Docker builds, before deployment)? - in the backend repo i have, it runs after the docker builds
19. Do we need to split the pipeline into separate jobs for plan vs. apply stages? - stages

## Testing & Validation

20. How will we test and validate the Terraform configuration locally before committing? - whatever is simplest

---

**Next Steps:** Answer these questions to inform the detailed plan.md file.
