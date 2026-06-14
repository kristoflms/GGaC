# HCP Terraform & GitHub Authentication Setup

## Overview
This guide covers authenticating with HCP Terraform (state backend) and GitHub (provider) for both local development and CI/CD.

## Prerequisites
- HCP Terraform account (https://app.terraform.io)
- GitHub organization/repository access
- Terraform 1.6.0+

---

## Local Development Setup

### 1. Generate HCP Terraform API Token
1. Go to https://app.terraform.io/app/settings/tokens
2. Click "Create an API token"
3. Copy the token (you'll only see it once)

### 2. Create Terraform CLI Configuration
Create a file at one of these locations:
- **Linux/macOS**: `~/.terraformrc`
- **Windows**: `%APPDATA%\terraform.rc`

Add:
```hcl
credentials "app.terraform.io" {
  token = "YOUR_HCP_TERRAFORM_API_TOKEN"
}
```

### 3. Generate GitHub Personal Access Token (PAT)
1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Scopes needed:
   - `repo` (full control of private repositories)
   - `admin:repo_hook` (if managing webhooks)
4. Copy the token

### 4. Set Terraform Variables
```bash
# Bash/Zsh
export TF_VAR_github_token="YOUR_GITHUB_PAT"

# PowerShell
$env:TF_VAR_github_token="YOUR_GITHUB_PAT"
```

Or create `terraform.tfvars` (⚠️ **NEVER commit this**):
```hcl
github_token = "YOUR_GITHUB_PAT"
```

### 5. Test Local Authentication
```bash
cd tf-code
terraform init
terraform plan
```

---

## CI/CD Setup (GitHub Actions)

### 1. Configure Repository Secrets
In your GitHub repository settings:
- Go to **Settings** → **Secrets and variables** → **Actions**
- Add these secrets:
  - `TF_API_TOKEN`: Your HCP Terraform API token
  - `GITHUB_TOKEN`: Already available in Actions (auto-generated per job)

### 2. Verify Workflow
The `.github/workflows/terraform-deploy.yml` file is already configured to:
- Authenticate to HCP Terraform via `TF_API_TOKEN`
- Pass `GITHUB_TOKEN` to Terraform provider
- Run `plan` on PR, `apply` on main push

### 3. HCP Terraform Organization Setup
1. Go to https://app.terraform.io/app/organizations
2. Create or select your organization
3. Update `tf-code/providers.tf`:
   ```hcl
   backend "remote" {
     hostname     = "app.terraform.io"
     organization = "YOUR_ORG_NAME"  # Replace with actual org
     
     workspaces {
       name = "YOUR_WORKSPACE_NAME"  # Replace with actual workspace
     }
   }
   ```
4. Create the workspace in HCP Terraform UI or let Terraform create it

---

## Security Best Practices

### Token Scope Principle (Least Privilege)
- **HCP Terraform Token**: Use a workspace-specific token or org token with minimal scope
- **GitHub Token**: Use action-generated `GITHUB_TOKEN` for Actions; personal PAT for local dev only

### Never Commit Secrets
- Add to `.gitignore`:
  ```
  terraform.tfvars
  terraform.tfvars.json
  .terraform/
  ```
- Rotate tokens immediately if accidentally exposed

### Token Rotation
- Rotate HCP Terraform tokens every 90 days
- Rotate GitHub PAT every 90 days or when leaving the project

---

## Troubleshooting

### Local: "No valid credential sources available"
- Verify `~/.terraformrc` exists and is readable
- Check token is valid: `terraform login app.terraform.io`

### CI/CD: "Invalid API token"
- Confirm `TF_API_TOKEN` secret is set in GitHub
- Regenerate token in HCP Terraform if expired

### "Resource not owned by organization"
- Ensure organization name matches `providers.tf`
- Verify workspace exists in HCP Terraform

### GitHub Provider Authentication Fails
- Verify `GITHUB_TOKEN` is being passed as `TF_VAR_github_token`
- Check GitHub PAT has required scopes (local dev)
- In Actions, built-in `GITHUB_TOKEN` is always available
