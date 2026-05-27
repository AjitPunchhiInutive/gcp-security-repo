locals {
  org_policy_config_files = [
    "sw-unified-data-platform/sw-unified-data-platform-folder.yaml",
    "sw-ent-networking/sw-ent-networking-folder.yaml",
    "sw-ent-security/sw-ent-security-folder.yaml",
    "custom_policy.yaml",
  ]

  active_org_policies = {
    for f in local.org_policy_config_files :
    f => yamldecode(file("config/org-policy/${f}"))
    if lookup(yamldecode(file("config/org-policy/${f}")), "deploy", false) == true
  }
}

module "orgpolicy" {
  source = "git@github.com:AjitPunchhiInutive/-sw-prod-udp-rds-infra-modules.git//orgpolicy?ref=custom-org-policy"

  for_each = local.active_org_policies

  org_policies = each.value
}

# ── State migration: renamed modules → for_each instances ────────────────────
moved {
  from = module.orgpolicy_networking
  to   = module.orgpolicy["sw-ent-networking/sw-ent-networking-folder.yaml"]
}

moved {
  from = module.orgpolicy_security
  to   = module.orgpolicy["sw-ent-security/sw-ent-security-folder.yaml"]
}

moved {
  from = module.orgpolicy_udp
  to   = module.orgpolicy["sw-unified-data-platform/sw-unified-data-platform-folder.yaml"]
}
