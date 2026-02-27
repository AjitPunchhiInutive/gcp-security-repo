locals {
  # Load all org-policy YAMLs dynamically
  org_policy_config_files = fileset(
    "${path.module}/config/org-policy",
    "*/*.yaml"
  )

  org_policy_objects = [
    for f in local.org_policy_config_files :
    yamldecode(file("${path.module}/config/org-policy/${f}"))
  ]
}

module "orgpolicy" {
  source = "git::https://github.com/AjitPunchhiInutive/-sw-prod-udp-rds-infra-modules.git//orgpolicy?ref=main"

  count = length(local.org_policy_objects) > 0 ? 1 : 0

  org_policies = local.org_policy_objects[0]
}