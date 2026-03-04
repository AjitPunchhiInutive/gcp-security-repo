locals {
  org_policy_config_files = [
    "sw-unified-data-platform/sw-unified-data-platform-folder.yaml",
    "sw-ent-networking/sw-ent-networking-folder.yaml",
    "sw-ent-security/sw-ent-security-folder.yaml",
  ]

  active_org_policies = {
    for f in local.org_policy_config_files :
    f => yamldecode(file("config/org-policy/${f}"))
    if lookup(yamldecode(file("config/org-policy/${f}")), "deploy", false) == true
  }
}

module "orgpolicy" {
  source = "git@github.com:AjitPunchhiInutive/-sw-prod-udp-rds-infra-modules.git//orgpolicy?ref=main"

  for_each = local.active_org_policies

  org_policies = each.value
}