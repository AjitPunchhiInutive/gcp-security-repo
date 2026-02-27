locals {
  # Org-policy: single object from first file in config/org-policy/sw-unified-data-platform/*.yaml
  org_policy_config_files = fileset(
    "${path.module}/config/org-policy/sw-unified-data-platform",
    "*.yaml"
  )

  org_policy_objects = [
    for f in local.org_policy_config_files :
    yamldecode(
      file("${path.module}/config/org-policy/sw-unified-data-platform/${f}")
    )
  ]

  # Use first YAML if present, otherwise pass null
  org_policies = length(local.org_policy_objects) > 0 ? local.org_policy_objects[0] : null
}

module "orgpolicy" {
  source       = "git::https://github.com/AjitPunchhiInutive/-sw-prod-udp-rds-infra-modules.git//orgpolicy?ref=main"
  org_policies = local.org_policies
}