locals {

  # Load ALL org-policy YAML files across all folders
  org_policy_config_files = fileset(
    "config/org-policy","*/*.yaml"
  )

  org_policy_objects = [
    for f in local.org_policy_config_files :
    yamldecode(
      file("config/org-policy/${f}")
    )
  ]

  # Filter only deploy=true policies
  active_org_policies = [
    for p in local.org_policy_objects :
    p if lookup(p, "deploy", false) == true
  ]
}

module "orgpolicy" {

  source = "git::ssh://git@github.com/AjitPunchhiInutive/-sw-prod-udp-rds-infra-modules.git//orgpolicy?ref=main"

  # Create one module instance per YAML
  for_each = {
    for idx, policy in local.active_org_policies :
    idx => policy
  }

  org_policies = each.value
}