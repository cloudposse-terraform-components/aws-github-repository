locals {
  enabled = module.this.enabled
}

module "repository" {
  source  = "cloudposse/repository/github"
  version = "0.2.0"

  enabled = local.enabled

  name = var.repository.name

  description = var.repository.description
  visibility  = var.repository.visibility

  template = var.template

  homepage_url = var.repository.homepage_url
  topics       = var.repository.topics

  archived           = var.repository.archived
  archive_on_destroy = var.repository.archive_on_destroy

  is_template = var.repository.is_template

  has_discussions = var.repository.has_discussions
  has_downloads   = var.repository.has_downloads
  has_issues      = var.repository.has_issues
  has_projects    = var.repository.has_projects
  has_wiki        = var.repository.has_wiki

  allow_squash_merge = var.repository.allow_squash_merge
  allow_merge_commit = var.repository.allow_merge_commit
  allow_rebase_merge = var.repository.allow_rebase_merge

  squash_merge_commit_title   = var.repository.squash_merge_commit_title
  squash_merge_commit_message = var.repository.squash_merge_commit_message

  allow_auto_merge = var.repository.allow_auto_merge

  merge_commit_title   = var.repository.merge_commit_title
  merge_commit_message = var.repository.merge_commit_message

  allow_update_branch    = var.repository.allow_update_branch
  delete_branch_on_merge = var.repository.delete_branch_on_merge

  auto_init          = var.repository.auto_init
  gitignore_template = var.repository.gitignore_template
  license_template   = var.repository.license_template

  web_commit_signoff_required = var.repository.web_commit_signoff_required

  ignore_vulnerability_alerts_during_read = var.repository.ignore_vulnerability_alerts_during_read

  default_branch              = var.repository.default_branch
  enable_vulnerability_alerts = var.repository.enable_vulnerability_alerts
  security_and_analysis       = var.repository.security_and_analysis

  autolink_references = var.autolink_references

  custom_properties = var.custom_properties
  environments      = local.environments

  variables   = local.variables
  secrets     = local.secrets
  deploy_keys = var.deploy_keys
  webhooks    = var.webhooks
  labels      = var.labels
  teams       = var.teams
  users       = var.users
  rulesets    = var.rulesets
}

locals {
  secrets = sensitive({
    for k, v in coalesce(var.secrets, {}) : k => (
      startswith(v, "ssm:") ? data.aws_ssm_parameter.default[v].value :
      startswith(v, "sm:") ? data.aws_secretsmanager_secret_version.default[v].secret_string : v
    )
  })

  variables = {
    for k, v in try(var.variables, {}) : k => (
      startswith(v, "ssm:") ? nonsensitive(data.aws_ssm_parameter.default[v].value) :
      startswith(v, "sm:") ? nonsensitive(data.aws_secretsmanager_secret_version.default[v].secret_string) : v
    )
  }

  environments = {
    for k, v in coalesce(var.environments, {}) : k => {
      wait_timer          = v.wait_timer
      can_admins_bypass   = v.can_admins_bypass
      prevent_self_review = v.prevent_self_review
      variables = {
        for name, variable in coalesce(v.variables, {}) : name => (
          startswith(variable, "ssm:") ? nonsensitive(data.aws_ssm_parameter.default[variable].value) :
          startswith(variable, "sm:") ? nonsensitive(data.aws_secretsmanager_secret_version.default[variable].secret_string) : variable
        )
      }
      secrets = {
        for name, secret in coalesce(v.secrets, {}) : name => (
          startswith(secret, "ssm:") ? nonsensitive(data.aws_ssm_parameter.default[secret].value) :
          startswith(secret, "sm:") ? nonsensitive(data.aws_secretsmanager_secret_version.default[secret].secret_string) : secret
        )
      }
    }
  }

  ssm_parameters = merge(flatten([
    [
      {
        for k, v in coalesce(var.variables, {}) : v => trimprefix(v, "ssm:") if startswith(v, "ssm:")
      },
      {
        for k, v in coalesce(var.secrets, {}) : v => trimprefix(v, "ssm:") if startswith(v, "ssm:")
      },
    ],
    [
      for k, v in coalesce(var.environments, {}) : {
        for name, variable in coalesce(v.variables, {}) : variable => trimprefix(variable, "ssm:") if startswith(variable, "ssm:")
      }
    ],
    [
      for k, v in coalesce(var.environments, {}) : {
        for name, secret in coalesce(v.secrets, {}) : secret => trimprefix(secret, "ssm:") if startswith(secret, "ssm:")
      }
    ]
  ])...)


  sm_parameters = merge(flatten([
    [
      {
        for k, v in coalesce(var.variables, {}) : v => trimprefix(v, "sm:") if startswith(v, "sm:")
      },
      {
        for k, v in coalesce(var.secrets, {}) : v => trimprefix(v, "sm:") if startswith(v, "sm:")
      },
    ],
    [
      for k, v in coalesce(var.environments, {}) : {
        for name, variable in coalesce(v.variables, {}) : variable => trimprefix(variable, "sm:") if startswith(variable, "sm:")
      }
    ],
    [
      for k, v in coalesce(var.environments, {}) : {
        for name, secret in coalesce(v.secrets, {}) : secret => trimprefix(secret, "sm:") if startswith(secret, "sm:")
      }
    ]
  ])...)
}

data "aws_ssm_parameter" "default" {
  for_each = nonsensitive(local.ssm_parameters)

  name = each.value
}

data "aws_secretsmanager_secret" "default" {
  for_each = nonsensitive(local.sm_parameters)

  name = each.value
}

data "aws_secretsmanager_secret_version" "default" {
  for_each = nonsensitive(local.sm_parameters)

  secret_id = data.aws_secretsmanager_secret.default[each.key].id
}
