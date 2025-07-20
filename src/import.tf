locals {
  import = local.enabled && var.import

  environments_exists = local.import ? data.github_repository_environments.default[var.repository.name].environments[*].name : []
}

// Check if the repository exists
data "github_repository" "default" {
  for_each = toset(local.import ? [var.repository.name] : [])
  full_name = format("%s/%s", var.owner, each.value)
}

import {
  for_each = data.github_repository.default
  id = each.value.name
  to = module.repository.github_repository.default[0]
}

import {
  for_each = data.github_repository.default
  id = each.value.name
  to = module.repository.github_repository_collaborators.default[0]
}

data "github_repository_environments" "default" {
  for_each = toset(local.import ? [var.repository.name] : [])
  repository = each.value
}

import {
  for_each = toset(local.environments_exists)
  id = format("%s:%s", var.repository.name, each.value)
  to = module.repository.github_repository_environment.default[each.value]
}

data "github_actions_environment_variables" "default" {
  for_each = toset(local.environments_exists)
  name = var.repository.name
  environment = each.value
}

locals {
  environments_variables = local.import ? flatten([
    for environment in local.environments_exists : [
        for variable in data.github_actions_environment_variables.default[environment].variables[*].name : 
            {environment = environment, variable = lower(variable), key = format("%s-%s", environment, lower(variable))} 
            if contains([ for i in keys(local.environments[environment].variables) : lower(i) ], lower(variable))
    ]
  ]) : []
}

import {
  for_each = toset(nonsensitive(local.environments_variables))
  id = format("%s:%s:%s", var.repository.name, each.value.environment, each.value.variable)
  to = module.repository.github_actions_environment_variable.default[each.value.key]
}

data "github_repository_autolink_references" "default" {
  for_each = toset(local.import ? [var.repository.name] : [])
  repository = each.value
}

locals {
  autolink_references = local.import ? {for k,v in var.autolink_references : v.key_prefix => k} : {}
  autolink_references_exists = local.import ? [
    for i in data.github_repository_autolink_references.default[var.repository.name].autolink_references[*] : {
        id = format("%s/%s", var.repository.name, i.key_prefix)
        name = local.autolink_references[i.key_prefix]
    } if can(local.autolink_references[i.key_prefix])
  ] : []
}

import {
  for_each = toset(local.autolink_references_exists)
  id = each.value.id
  to = module.repository.github_repository_autolink_reference.default[each.value.name]
}

data "github_actions_variables" "default" {
  for_each = toset(local.import ? [var.repository.name] : [])
  name = each.value
}

locals {
  variables_exists = local.import ? [
    for variable in data.github_actions_variables.default[var.repository.name].variables[*].name : lower(variable) 
    if contains([ for i in keys(var.variables) : lower(i) ], lower(variable))
  ] : []
}

import {
  for_each = toset(local.variables_exists)
  id = format("%s:%s", var.repository.name, each.value)
  to = module.repository.github_actions_variable.default[each.value]
}

data "github_repository_custom_properties" "default" {
  for_each = toset(local.import ? [var.repository.name] : [])
  repository = each.value
}

locals {
  custom_properties_exists = local.import ? [
    for property in data.github_repository_custom_properties.default[var.repository.name].property[*].property_name : lower(property) 
    if contains([ for i in keys(var.custom_properties) : lower(i) ], lower(property))
  ] : []
}

import {
  for_each = toset(local.custom_properties_exists)
  id = format("%s:%s:%s", var.owner, var.repository.name, each.value)
  to = module.repository.github_repository_custom_property.default[each.value]
}


data "github_repository_deploy_keys" "default" {
  for_each = toset(local.import ? [var.repository.name] : [])
  repository = each.value
}

locals {
  deploy_keys = local.import ? {for k,v in var.deploy_keys : v.key => k} : {}
  deploy_keys_exists = local.import ? [
    for item in data.github_repository_deploy_keys.default[var.repository.name].keys : {
        id = format("%s:%s", var.repository.name, item.id)
        name = local.deploy_keys[item.key]
    } if can(local.deploy_keys[item.key])
  ] : []
}

import {
  for_each = toset(local.deploy_keys_exists)
  id = each.value.id
  to = module.repository.github_repository_deploy_key.default[each.value.name]
}


data "github_issue_labels" "default" {
  for_each = toset(local.import ? [var.repository.name] : [])
  repository = each.value
}

locals {
  labels_exists = local.import ? [
    for item in data.github_issue_labels.default[var.repository.name].labels : {
        id = format("%s:%s", var.repository.name, item.name)
        name = item.name
    } if can(var.labels[item.name])
  ] : []
}

import {
  for_each = toset(local.labels_exists)
  id = each.value.id
  to = module.repository.github_issue_label.default[each.value.name]
}
