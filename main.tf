locals {
  udp_yaml        = yamldecode(file("config/org-policy/sw-unified-data-platform/sw-unified-data-platform-folder.yaml"))
  networking_yaml = yamldecode(file("config/org-policy/sw-ent-networking/sw-ent-networking-folder.yaml"))
  security_yaml   = yamldecode(file("config/org-policy/sw-ent-security/sw-ent-security-folder.yaml"))

  networking_project_overrides = yamldecode(file("config/org-policy/sw-ent-networking/sw-ent-networking-project-overrides.yaml"))
}

# Modules are chained via depends_on to serialize GCP org policy API writes.
# All three folders share the same ID in the test environment, so concurrent
# writes cause 409 "aborted" errors. In production each folder ID is unique.

module "orgpolicy_udp" {
  source       = "git@github.com:AjitPunchhiInutive/-sw-prod-udp-rds-infra-modules.git//orgpolicy?ref=feature/orgpolicy-dryrun"
  org_policies = local.udp_yaml
}

module "orgpolicy_networking" {
  source       = "git@github.com:AjitPunchhiInutive/-sw-prod-udp-rds-infra-modules.git//orgpolicy?ref=feature/orgpolicy-dryrun"
  org_policies = local.networking_yaml
  depends_on   = [module.orgpolicy_udp]
}

module "orgpolicy_security" {
  source       = "git@github.com:AjitPunchhiInutive/-sw-prod-udp-rds-infra-modules.git//orgpolicy?ref=feature/orgpolicy-dryrun"
  org_policies = local.security_yaml
  depends_on   = [module.orgpolicy_networking]
}

# Migrate state from the old for_each module to the new explicit modules.
# No resources are destroyed — this is a rename-only operation.
module "orgpolicy_networking_projects" {
  source   = "git@github.com:AjitPunchhiInutive/-sw-prod-udp-rds-infra-modules.git//orgpolicy?ref=feature/orgpolicy-dryrun"
  for_each = { for o in local.networking_project_overrides : o.project_id => o }

  org_policies = {
    deploy         = true
    project_id     = each.value.project_id
    policy_boolean = try(each.value.policy_boolean, {})
    policy_list    = try(each.value.policy_list, {})
  }

  depends_on = [module.orgpolicy_networking]
}

moved {
  from = module.orgpolicy["sw-unified-data-platform/sw-unified-data-platform-folder.yaml"]
  to   = module.orgpolicy_udp
}
moved {
  from = module.orgpolicy["sw-ent-networking/sw-ent-networking-folder.yaml"]
  to   = module.orgpolicy_networking
}
moved {
  from = module.orgpolicy["sw-ent-security/sw-ent-security-folder.yaml"]
  to   = module.orgpolicy_security
}
