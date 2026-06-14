terraform {
  required_version = ">= 1.6.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5.0.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io" # HCP / TFC
    organization = "Lets-make-it-simple-dot-tech"

    workspaces {
      name = "workspace-a"
    }
  }
}

provider "github" {
  token = var.github_token
}