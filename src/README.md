Provision a GitHub repository and set repository secrets and variables from AWS Secrets Manager and AWS Systems Manager Parameter Store.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.
```yaml
components:
  terraform:
    example/aws-github-repository:
      vars:
        enabled: true
        owner: acme-github-org
        repository:
          name: "my-repository"
          description: "My repository"
          homepage_url: "http://example.com/"
          topics:
            - terraform
            - github
            - test
        default_branch: "main"
        secrets:
          MY_SECRET: "my-secret-value"
          MY_SECRET_2: "nacl:dGVzdC12YWx1ZS0yCg=="
          MY_SECRET_3: "ssm:///my/secret/path"
          MY_SECRET_4: "asm://secret-name"
        variables:
          MY_VARIABLE: "my-variable-value"
          MY_VARIABLE_2: "ssm:///my/variable/path"
          MY_VARIABLE_3: "asm://variable-name"
```

## Secrets and variables

The component supports setting repository and environment secrets and variables.
Secrets and variables can be set using the following methods:
- Raw values (unencrypted string) (example: `my-secret-value`)
- AWS Secrets Manager (SM) (example: `asm://secret-name`)
- AWS Systems Manager Parameter Store (SSM) (example: `ssm:///my/secret/path`)

In addition to that secrets supports base64 encoded values [encrypted](https://docs.github.com/en/rest/guides/encrypting-secrets-for-the-rest-api?apiVersion=2022-11-28)
with [repository key](https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#get-a-repository-public-key).
The value should be prefixed with `nacl:` (example: `nacl:dGVzdC12YWx1ZS0yCg==`).

## Import mode

The component supports importing existing repository and it's configs:
- collaborators
- variables
- environments
- environment variables
- labels
- custom properties values
- autolink references
- deploy keys

Import mode is enabled by setting `import` input variable to `true`.

The following configs are not supported for import:
- secrets
- environment secrets
- branch protection policies
- rulesets

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_github"></a> [github](#provider\_github) | >= 6.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_repository"></a> [repository](#module\_repository) | cloudposse/repository/github | 0.2.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [github_actions_environment_variables.default](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/actions_environment_variables) | data source |
| [github_actions_variables.default](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/actions_variables) | data source |
| [github_issue_labels.default](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/issue_labels) | data source |
| [github_repository.default](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository) | data source |
| [github_repository_autolink_references.default](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository_autolink_references) | data source |
| [github_repository_custom_properties.default](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository_custom_properties) | data source |
| [github_repository_deploy_keys.default](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository_deploy_keys) | data source |
| [github_repository_environments.default](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository_environments) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_autolink_references"></a> [autolink\_references](#input\_autolink\_references) | Autolink references | <pre>map(object({<br/>    key_prefix          = string<br/>    target_url_template = string<br/>    is_alphanumeric     = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_custom_properties"></a> [custom\_properties](#input\_custom\_properties) | Custom properties for the repository | <pre>map(object({<br/>    string        = optional(string, null)<br/>    boolean       = optional(bool, null)<br/>    single_select = optional(string, null)<br/>    multi_select  = optional(list(string), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_deploy_keys"></a> [deploy\_keys](#input\_deploy\_keys) | Deploy keys for the repository | <pre>map(object({<br/>    title     = string<br/>    key       = string<br/>    read_only = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | Environments for the repository. Enviroment secrets should be encrypted using the GitHub public key in Base64 format if prefixed with nacl:. Read more: https://docs.github.com/en/actions/security-for-github-actions/encrypted-secrets | <pre>map(object({<br/>    wait_timer          = optional(number, 0)<br/>    can_admins_bypass   = optional(bool, false)<br/>    prevent_self_review = optional(bool, false)<br/>    reviewers = optional(object({<br/>      teams = optional(list(string), [])<br/>      users = optional(list(string), [])<br/>    }), null)<br/>    deployment_branch_policy = optional(object({<br/>      protected_branches = optional(bool, false)<br/>      custom_branches = optional(object({<br/>        branches = optional(list(string), null)<br/>        tags     = optional(list(string), null)<br/>      }), null)<br/>    }), null)<br/>    variables = optional(map(string), null)<br/>    secrets   = optional(map(string), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import"></a> [import](#input\_import) | Import repository | `bool` | `false` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of labels to configure for the repository | <pre>map(object({<br/>    color       = string<br/>    description = string<br/>  }))</pre> | `{}` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner of the repository | `string` | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository configuration | <pre>object({<br/>    name                                    = string<br/>    description                             = optional(string, null)<br/>    visibility                              = optional(string, "public")<br/>    homepage_url                            = optional(string, null)<br/>    archived                                = optional(bool, false)<br/>    has_issues                              = optional(bool, false)<br/>    has_projects                            = optional(bool, false)<br/>    has_discussions                         = optional(bool, false)<br/>    has_wiki                                = optional(bool, false)<br/>    has_downloads                           = optional(bool, false)<br/>    is_template                             = optional(bool, false)<br/>    allow_auto_merge                        = optional(bool, false)<br/>    allow_squash_merge                      = optional(bool, true)<br/>    squash_merge_commit_title               = optional(string, "PR_TITLE")<br/>    squash_merge_commit_message             = optional(string, "PR_BODY")<br/>    allow_merge_commit                      = optional(bool, true)<br/>    merge_commit_title                      = optional(string, "PR_TITLE")<br/>    merge_commit_message                    = optional(string, "PR_BODY")<br/>    allow_rebase_merge                      = optional(bool, true)<br/>    delete_branch_on_merge                  = optional(bool, false)<br/>    default_branch                          = optional(string, "main")<br/>    web_commit_signoff_required             = optional(bool, false)<br/>    topics                                  = optional(list(string), [])<br/>    license_template                        = optional(string, null)<br/>    gitignore_template                      = optional(string, null)<br/>    auto_init                               = optional(bool, false)<br/>    ignore_vulnerability_alerts_during_read = optional(bool, false)<br/>    enable_vulnerability_alerts             = optional(bool, true)<br/>    allow_update_branch                     = optional(bool, false)<br/>    security_and_analysis = optional(object({<br/>      advanced_security               = bool<br/>      secret_scanning                 = bool<br/>      secret_scanning_push_protection = bool<br/>    }), null)<br/>    archive_on_destroy = optional(bool, false)<br/>  })</pre> | n/a | yes |
| <a name="input_rulesets"></a> [rulesets](#input\_rulesets) | A map of rulesets to configure for the repository | <pre>map(object({<br/>    name = string<br/>    # disabled, active<br/>    enforcement = string<br/>    # branch, tag<br/>    target = string<br/>    bypass_actors = optional(list(object({<br/>      # always, pull_request<br/>      bypass_mode = string<br/>      actor_id    = optional(string, null)<br/>      # RepositoryRole, Team, Integration, OrganizationAdmin<br/>      actor_type = string<br/>    })), [])<br/>    conditions = object({<br/>      ref_name = object({<br/>        # Supports ~DEFAULT_BRANCH or ~ALL<br/>        include = optional(list(string), [])<br/>        exclude = optional(list(string), [])<br/>      })<br/>    })<br/>    rules = object({<br/>      branch_name_pattern = optional(object({<br/>        # starts_with, ends_with, contains, regex<br/>        operator = string<br/>        pattern  = string<br/>        name     = optional(string, null)<br/>        negate   = optional(bool, false)<br/>      }), null),<br/>      commit_author_email_pattern = optional(object({<br/>        # starts_with, ends_with, contains, regex<br/>        operator = string<br/>        pattern  = string<br/>        name     = optional(string, null)<br/>        negate   = optional(bool, false)<br/>      }), null),<br/>      creation         = optional(bool, false),<br/>      deletion         = optional(bool, false),<br/>      non_fast_forward = optional(bool, false),<br/>      required_pull_request_reviews = optional(object({<br/>        dismiss_stale_reviews           = bool<br/>        required_approving_review_count = number<br/>      }), null),<br/>      commit_message_pattern = optional(object({<br/>        # starts_with, ends_with, contains, regex<br/>        operator = string<br/>        pattern  = string<br/>        name     = optional(string, null)<br/>        negate   = optional(bool, false)<br/>      }), null),<br/>      committer_email_pattern = optional(object({<br/>        # starts_with, ends_with, contains, regex<br/>        operator = string<br/>        pattern  = string<br/>        name     = optional(string, null)<br/>        negate   = optional(bool, false)<br/>      }), null),<br/>      merge_queue = optional(object({<br/>        check_response_timeout_minutes = optional(number, 60)<br/>        # ALLGREEN, HEADGREEN<br/>        grouping_strategy    = string<br/>        max_entries_to_build = optional(number, 5)<br/>        max_entries_to_merge = optional(number, 5)<br/>        # MERGE, SQUASH, REBASE<br/>        merge_method                      = optional(string, "MERGE")<br/>        min_entries_to_merge              = optional(number, 1)<br/>        min_entries_to_merge_wait_minutes = optional(number, 5)<br/>      }), null),<br/>      pull_request = optional(object({<br/>        dismiss_stale_reviews_on_push     = optional(bool, false)<br/>        require_code_owner_review         = optional(bool, false)<br/>        require_last_push_approval        = optional(bool, false)<br/>        required_approving_review_count   = optional(number, 0)<br/>        required_review_thread_resolution = optional(bool, false)<br/>      }), null),<br/>      required_deployments = optional(object({<br/>        required_deployment_environments = optional(list(string), [])<br/>      }), null),<br/>      required_status_checks = optional(object({<br/>        required_check = list(object({<br/>          context        = string<br/>          integration_id = optional(number, null)<br/>        }))<br/>        strict_required_status_checks_policy = optional(bool, false)<br/>        do_not_enforce_on_create             = optional(bool, false)<br/>      }), null),<br/>      tag_name_pattern = optional(object({<br/>        # starts_with, ends_with, contains, regex<br/>        operator = string<br/>        pattern  = string<br/>        name     = optional(string, null)<br/>        negate   = optional(bool, false)<br/>      }), null),<br/>      # Unsupported due to drift.<br/>      # https://github.com/integrations/terraform-provider-github/pull/2701<br/>      # required_code_scanning = optional(object({<br/>      #   required_code_scanning_tool = list(object({<br/>      #     // none, errors, errors_and_warnings, all<br/>      #     alerts_threshold          = string<br/>      #     // none, critical, high_or_higher, medium_or_higher, all<br/>      #     security_alerts_threshold = string<br/>      #     tool                      = string<br/>      #   }))<br/>      # }), null),<br/>    }),<br/>  }))</pre> | `{}` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets for the repository (if prefixed with nacl: it should be encrypted value using the GitHub public key in Base64 format. Read more: https://docs.github.com/en/actions/security-for-github-actions/encrypted-secrets) | `map(string)` | `{}` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_teams"></a> [teams](#input\_teams) | A map of teams and their permissions for the repository | `map(string)` | `{}` | no |
| <a name="input_template"></a> [template](#input\_template) | Template repository | <pre>object({<br/>    owner                = string<br/>    name                 = string<br/>    include_all_branches = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_users"></a> [users](#input\_users) | A map of users and their permissions for the repository | `map(string)` | `{}` | no |
| <a name="input_variables"></a> [variables](#input\_variables) | Environment variables for the repository | `map(string)` | `{}` | no |
| <a name="input_webhooks"></a> [webhooks](#input\_webhooks) | A map of webhooks to configure for the repository | <pre>map(object({<br/>    active       = optional(bool, true)<br/>    events       = list(string)<br/>    url          = string<br/>    content_type = optional(string, "json")<br/>    insecure_ssl = optional(bool, false)<br/>    secret       = optional(string, null)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_collaborators_invitation_ids"></a> [collaborators\_invitation\_ids](#output\_collaborators\_invitation\_ids) | Collaborators invitation IDs |
| <a name="output_full_name"></a> [full\_name](#output\_full\_name) | Full name of the created repository |
| <a name="output_git_clone_url"></a> [git\_clone\_url](#output\_git\_clone\_url) | Git clone URL of the created repository |
| <a name="output_html_url"></a> [html\_url](#output\_html\_url) | HTML URL of the created repository |
| <a name="output_http_clone_url"></a> [http\_clone\_url](#output\_http\_clone\_url) | HTTP clone URL of the created repository |
| <a name="output_node_id"></a> [node\_id](#output\_node\_id) | Node ID of the created repository |
| <a name="output_primary_language"></a> [primary\_language](#output\_primary\_language) | Primary language of the created repository |
| <a name="output_repo_id"></a> [repo\_id](#output\_repo\_id) | Repository ID of the created repository |
| <a name="output_rulesets_etags"></a> [rulesets\_etags](#output\_rulesets\_etags) | Rulesets etags |
| <a name="output_rulesets_node_ids"></a> [rulesets\_node\_ids](#output\_rulesets\_node\_ids) | Rulesets node IDs |
| <a name="output_rulesets_rules_ids"></a> [rulesets\_rules\_ids](#output\_rulesets\_rules\_ids) | Rulesets rules IDs |
| <a name="output_ssh_clone_url"></a> [ssh\_clone\_url](#output\_ssh\_clone\_url) | SSH clone URL of the created repository |
| <a name="output_svn_url"></a> [svn\_url](#output\_svn\_url) | SVN URL of the created repository |
| <a name="output_webhooks_urls"></a> [webhooks\_urls](#output\_webhooks\_urls) | Webhooks URLs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->
