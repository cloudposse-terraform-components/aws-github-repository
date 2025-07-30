variable "region" {
  type        = string
  description = "AWS Region"
}

variable "import" {
  description = "Import repository"
  type        = bool
  default     = false
}

variable "repository" {
  description = "Repository configuration"
  type = object({
    name                                    = string
    description                             = optional(string, null)
    visibility                              = optional(string, "public")
    homepage_url                            = optional(string, null)
    archived                                = optional(bool, false)
    has_issues                              = optional(bool, false)
    has_projects                            = optional(bool, false)
    has_discussions                         = optional(bool, false)
    has_wiki                                = optional(bool, false)
    has_downloads                           = optional(bool, false)
    is_template                             = optional(bool, false)
    allow_auto_merge                        = optional(bool, false)
    allow_squash_merge                      = optional(bool, true)
    squash_merge_commit_title               = optional(string, "PR_TITLE")
    squash_merge_commit_message             = optional(string, "PR_BODY")
    allow_merge_commit                      = optional(bool, true)
    merge_commit_title                      = optional(string, "PR_TITLE")
    merge_commit_message                    = optional(string, "PR_BODY")
    allow_rebase_merge                      = optional(bool, true)
    delete_branch_on_merge                  = optional(bool, false)
    default_branch                          = optional(string, "main")
    web_commit_signoff_required             = optional(bool, false)
    topics                                  = optional(list(string), [])
    license_template                        = optional(string, null)
    gitignore_template                      = optional(string, null)
    auto_init                               = optional(bool, false)
    ignore_vulnerability_alerts_during_read = optional(bool, false)
    enable_vulnerability_alerts             = optional(bool, true)
    allow_update_branch                     = optional(bool, false)
    security_and_analysis = optional(object({
      advanced_security               = bool
      secret_scanning                 = bool
      secret_scanning_push_protection = bool
    }), null)
    archive_on_destroy = optional(bool, false)
  })

  validation {
    condition     = try(contains(["public", "private", "internal"], var.repository.visibility), true)
    error_message = "Repository visibility must be public, private or internal"
  }

  validation {
    condition     = try(contains(["PR_TITLE", "COMMIT_OR_PR_TITLE"], var.repository.squash_merge_commit_title), true)
    error_message = "Repository squash merge commit title must be PR_TITLE, COMMIT_OR_PR_TITLE"
  }

  validation {
    condition     = try(contains(["PR_BODY", "COMMIT_MESSAGES", "BLANK"], var.repository.squash_merge_commit_message), true)
    error_message = "Repository squash merge commit message must be PR_BODY, COMMIT_MESSAGES or BLANK"
  }

  validation {
    condition     = try(contains(["PR_TITLE", "MERGE_MESSAGE"], var.repository.merge_commit_title), true)
    error_message = "Repository merge commit title must be PR_TITLE, MERGE_MESSAGE"
  }

  validation {
    condition     = try(contains(["PR_BODY", "PR_TITLE", "BLANK"], var.repository.merge_commit_message), true)
    error_message = "Repository merge commit message must be PR_BODY, PR_TITLE or BLANK"
  }
}

variable "owner" {
  description = "Owner of the repository"
  type        = string
}

variable "template" {
  description = "Template repository"
  type = object({
    owner                = string
    name                 = string
    include_all_branches = optional(bool, false)
  })
  default = null
}

variable "autolink_references" {
  description = "Autolink references"
  type = map(object({
    key_prefix          = string
    target_url_template = string
    is_alphanumeric     = optional(bool, false)
  }))
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for k, v in var.autolink_references : can(regex("^http(s)?://", v.target_url_template))])
    error_message = "Autolink reference target URL template must start with http:// or https://"
  }

  validation {
    condition     = alltrue([for k, v in var.autolink_references : can(strcontains(v.key_prefix, "<num>"))])
    error_message = "Autolink reference key prefix must contain <num>"
  }
}

variable "custom_properties" {
  description = "Custom properties for the repository"
  type = map(object({
    string        = optional(string, null)
    boolean       = optional(bool, null)
    single_select = optional(string, null)
    multi_select  = optional(list(string), null)
  }))
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for k, v in var.custom_properties : length([for n, i in v : n if i != null]) == 1])
    error_message = "Custom property must have only one of the following: string, boolean, single_select, multi_select"
  }
}

variable "environments" {
  description = "Environments for the repository. Enviroment secrets should be encrypted using the GitHub public key in Base64 format if prefixed with nacl:. Read more: https://docs.github.com/en/actions/security-for-github-actions/encrypted-secrets"
  type = map(object({
    wait_timer          = optional(number, 0)
    can_admins_bypass   = optional(bool, false)
    prevent_self_review = optional(bool, false)
    reviewers = optional(object({
      teams = optional(list(string), [])
      users = optional(list(string), [])
    }), null)
    deployment_branch_policy = optional(object({
      protected_branches = optional(bool, false)
      custom_branches = optional(object({
        branches = optional(list(string), null)
        tags     = optional(list(string), null)
      }), null)
    }), null)
    variables = optional(map(string), null)
    secrets   = optional(map(string), null)
  }))
  default   = {}
  sensitive = true
  nullable  = false

  validation {
    condition     = alltrue([for k, v in var.environments : try(length(v.reviewers.teams) <= 6, true)])
    error_message = "Environment reviewers can not have more than 6 teams"
  }

  validation {
    condition     = alltrue([for k, v in var.environments : try(length(v.reviewers.users) <= 6, true)])
    error_message = "Environment reviewers can not have more than 6 users"
  }

  validation {
    condition     = alltrue([for k, v in var.environments : try(v.deployment_branch_policy.protected_branches == true || v.deployment_branch_policy.custom_branches != null, true)])
    error_message = "Environment deployment branch policy should have protected_branches set to true or custom_branches specified"
  }

  validation {
    condition     = alltrue([for k, v in var.environments : try(alltrue([for k, v in v.variables : can(regex("^[a-zA-Z0-9_]+$", k))]), true)])
    error_message = "Environment variables must be alphanumeric and underscores only, can not start with a number"
  }

  validation {
    condition     = alltrue([for k, v in var.environments : try(alltrue([for k, v in v.secrets : can(regex("^[a-zA-Z0-9_]+$", k))]), true)])
    error_message = "Environment secrets must be alphanumeric and underscores only, can not start with a number"
  }
}


variable "variables" {
  description = "Environment variables for the repository"
  type        = map(string)
  default     = {}
  nullable    = false

  validation {
    condition     = var.variables == null || alltrue([for k, v in var.variables : can(regex("^[a-zA-Z0-9_]+$", k))])
    error_message = "Variable names must be alphanumeric and underscores only, can not start with a number"
  }
}

variable "secrets" {
  description = "Secrets for the repository (if prefixed with nacl: it should be encrypted value using the GitHub public key in Base64 format. Read more: https://docs.github.com/en/actions/security-for-github-actions/encrypted-secrets)"
  type        = map(string)
  default     = {}
  sensitive   = true
  nullable    = false

  validation {
    condition     = var.secrets == null || alltrue([for k, v in var.secrets : can(regex("^[a-zA-Z0-9_]+$", k))])
    error_message = "Secret names must be alphanumeric and underscores only, can not start with a number"
  }
}

variable "deploy_keys" {
  description = "Deploy keys for the repository"
  type = map(object({
    title     = string
    key       = string
    read_only = optional(bool, false)
  }))
  default  = {}
  nullable = false
}

# https://docs.github.com/en/webhooks/webhook-events-and-payloads
variable "webhooks" {
  description = "A map of webhooks to configure for the repository"
  type = map(object({
    active       = optional(bool, true)
    events       = list(string)
    url          = string
    content_type = optional(string, "json")
    insecure_ssl = optional(bool, false)
    secret       = optional(string, null)
  }))
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for k, v in var.webhooks : can(regex("^http(s)?://", v.url))])
    error_message = "Webhook URL must start with http:// or https://"
  }

  validation {
    condition     = alltrue([for k, v in var.webhooks : contains(["json", "form"], v.content_type)])
    error_message = "Webhook content type must be json or form"
  }
}

variable "labels" {
  description = "A map of labels to configure for the repository"
  type = map(object({
    color       = string
    description = string
  }))
  default  = {}
  nullable = false
}

variable "teams" {
  description = "A map of teams and their permissions for the repository"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "users" {
  description = "A map of users and their permissions for the repository"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "rulesets" {
  description = "A map of rulesets to configure for the repository"
  type = map(object({
    name = string
    # disabled, active
    enforcement = string
    # branch, tag
    target = string
    bypass_actors = optional(list(object({
      # always, pull_request
      bypass_mode = string
      actor_id    = optional(string, null)
      # RepositoryRole, Team, Integration, OrganizationAdmin
      actor_type = string
    })), [])
    conditions = object({
      ref_name = object({
        # Supports ~DEFAULT_BRANCH or ~ALL
        include = optional(list(string), [])
        exclude = optional(list(string), [])
      })
    })
    rules = object({
      branch_name_pattern = optional(object({
        # starts_with, ends_with, contains, regex
        operator = string
        pattern  = string
        name     = optional(string, null)
        negate   = optional(bool, false)
      }), null),
      commit_author_email_pattern = optional(object({
        # starts_with, ends_with, contains, regex
        operator = string
        pattern  = string
        name     = optional(string, null)
        negate   = optional(bool, false)
      }), null),
      creation         = optional(bool, false),
      deletion         = optional(bool, false),
      non_fast_forward = optional(bool, false),
      required_pull_request_reviews = optional(object({
        dismiss_stale_reviews           = bool
        required_approving_review_count = number
      }), null),
      commit_message_pattern = optional(object({
        # starts_with, ends_with, contains, regex
        operator = string
        pattern  = string
        name     = optional(string, null)
        negate   = optional(bool, false)
      }), null),
      committer_email_pattern = optional(object({
        # starts_with, ends_with, contains, regex
        operator = string
        pattern  = string
        name     = optional(string, null)
        negate   = optional(bool, false)
      }), null),
      merge_queue = optional(object({
        check_response_timeout_minutes = optional(number, 60)
        # ALLGREEN, HEADGREEN
        grouping_strategy    = string
        max_entries_to_build = optional(number, 5)
        max_entries_to_merge = optional(number, 5)
        # MERGE, SQUASH, REBASE
        merge_method                      = optional(string, "MERGE")
        min_entries_to_merge              = optional(number, 1)
        min_entries_to_merge_wait_minutes = optional(number, 5)
      }), null),
      pull_request = optional(object({
        dismiss_stale_reviews_on_push     = optional(bool, false)
        require_code_owner_review         = optional(bool, false)
        require_last_push_approval        = optional(bool, false)
        required_approving_review_count   = optional(number, 0)
        required_review_thread_resolution = optional(bool, false)
      }), null),
      required_deployments = optional(object({
        required_deployment_environments = optional(list(string), [])
      }), null),
      required_status_checks = optional(object({
        required_check = list(object({
          context        = string
          integration_id = optional(number, null)
        }))
        strict_required_status_checks_policy = optional(bool, false)
        do_not_enforce_on_create             = optional(bool, false)
      }), null),
      tag_name_pattern = optional(object({
        # starts_with, ends_with, contains, regex
        operator = string
        pattern  = string
        name     = optional(string, null)
        negate   = optional(bool, false)
      }), null),
      # Unsupported due to drift.
      # https://github.com/integrations/terraform-provider-github/pull/2701
      # required_code_scanning = optional(object({
      #   required_code_scanning_tool = list(object({
      #     // none, errors, errors_and_warnings, all
      #     alerts_threshold          = string
      #     // none, critical, high_or_higher, medium_or_higher, all
      #     security_alerts_threshold = string
      #     tool                      = string
      #   }))
      # }), null),
    }),
  }))
  default = {}

  validation {
    condition     = alltrue([for k, v in var.rulesets : can(regex("^[a-zA-Z0-9_]+$", k))])
    error_message = "Ruleset names must be alphanumeric and underscores only, can not start with a number"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : contains(["disabled", "active", "evaluate"], v.enforcement)])
    error_message = "Ruleset enforcement must be disabled or active"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : contains(["branch", "tag"], v.target)])
    error_message = "Ruleset target must be branch or tag"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : try(contains(["always", "pull_request"], v.bypass_actors.bypass_mode), true)])
    error_message = "Ruleset bypass mode must be always or pull_request"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : try(contains(["RepositoryRole", "Team", "Integration", "OrganizationAdmin"], v.bypass_actors.actor_type), true)])
    error_message = "Ruleset actor type must be RepositoryRole, Team, Integration or OrganizationAdmin"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : try(contains(["starts_with", "ends_with", "contains", "regex"], v.rules.branch_name_pattern.operator), true)])
    error_message = "Ruleset branch name pattern operator must be starts_with, ends_with, contains or regex"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : v.target == "branch" || try(v.rules.branch_name_pattern == null, true)])
    error_message = "Ruleset branch name pattern can be specified only for branch rulesets"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : try(contains(["starts_with", "ends_with", "contains", "equals", "regex"], v.rules.commit_author_email_pattern.operator), true)])
    error_message = "Ruleset commit author email pattern operator must be starts_with, ends_with, contains, equals or regex"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : try(contains(["starts_with", "ends_with", "contains", "equals", "regex"], v.rules.commit_message_pattern.operator), true)])
    error_message = "Ruleset commit message pattern operator must be starts_with, ends_with, contains, equals or regex"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : try(contains(["starts_with", "ends_with", "contains", "equals", "regex"], v.rules.committer_email_pattern.operator), true)])
    error_message = "Ruleset committer email pattern operator must be starts_with, ends_with, contains, equals or regex"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : try(contains(["ALLGREEN", "HEADGREEN"], v.rules.merge_queue.grouping_strategy), true)])
    error_message = "Ruleset merge queue grouping strategy must be ALLGREEN or HEADGREEN"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : try(contains(["MERGE", "SQUASH", "REBASE"], v.rules.merge_queue.merge_method), true)])
    error_message = "Ruleset merge queue merge method must be MERGE, SQUASH or REBASE"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : v.rules.merge_queue == null || alltrue([for c in v.conditions.ref_name.include : can(!strcontains(c, "*") && !strcontains(c, "~ALL"))])])
    error_message = "Ruleset merge queue condition mush point to specific branch"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : try(contains(["starts_with", "ends_with", "contains", "regex"], v.rules.tag_name_pattern.operator), true)])
    error_message = "Ruleset branch name pattern operator must be starts_with, ends_with, contains or regex"
  }

  validation {
    condition     = alltrue([for k, v in var.rulesets : v.target == "tag" || try(v.rules.tag_name_pattern == null, true)])
    error_message = "Ruleset tag name pattern can be specified only for tag rulesets"
  }
}
