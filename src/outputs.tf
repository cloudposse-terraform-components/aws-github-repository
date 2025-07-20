output "full_name" {
  description = "Full name of the created repository"
  value       = module.repository.full_name
}

output "html_url" {
  description = "HTML URL of the created repository"
  value       = module.repository.html_url
}

output "ssh_clone_url" {
  description = "SSH clone URL of the created repository"
  value       = module.repository.ssh_clone_url
}

output "http_clone_url" {
  description = "SSH clone URL of the created repository"
  value       = module.repository.http_clone_url
}

output "git_clone_url" {
  description = "Git clone URL of the created repository"
  value       = module.repository.git_clone_url
}

output "svn_url" {
  description = "SVN URL of the created repository"
  value       = module.repository.svn_url
}

output "node_id" {
  description = "Node ID of the created repository"
  value       = module.repository.node_id
}

output "repo_id" {
  description = "Repository ID of the created repository"
  value       = module.repository.repo_id
}

output "primary_language" {
  description = "Primary language of the created repository"
  value       = module.repository.primary_language
}

output "webhooks_urls" {
  description = "Webhooks URLs"
  value       = module.repository.webhooks_urls
}

output "collaborators_invitation_ids" {
  description = "Collaborators invitation IDs"
  value       = module.repository.collaborators_invitation_ids
}

output "rulesets_etags" {
  description = "Rulesets etags"
  value       = module.repository.rulesets_etags
}

output "rulesets_node_ids" {
  description = "Rulesets node IDs"
  value       = module.repository.rulesets_node_ids
}

output "rulesets_rules_ids" {
  description = "Rulesets rules IDs"
  value       = module.repository.rulesets_rules_ids
}
