resource "github_repository" "ggac" {
  for_each    = var.repo_names
  name        = "${local.workspace_name}-${each.key}"
  description = "Repository created from workspace ${terraform.workspace}"
  visibility  = "private"
}

output "repo_names" {
  value = [for repo in github_repository.ggac : repo.name]
}

