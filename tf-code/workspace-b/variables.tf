variable "repo_instances" {
  type        = set(string)
  default     = ["inst-a", "inst-b", "inst-c"]
  description = "Unique keys for repository instances used with for_each."
}

variable "github_token" {
  description = "GitHub token with repository permissions. Set via CI/HCP workspace variable or environment."
  type        = string
  sensitive   = true
}

variable "repo_names" {
  type        = set(string)
  default     = ["repo-a", "repo-b", "repo-c"]
  description = "Unique names for repositories used with for_each."
}