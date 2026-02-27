locals {
# Org-policy: single object from first file in config/org-policy/*.yaml
  org_policy_config_files = fileset("config/org-policy/sw-unified-data-paltform", "*.yaml")
  org_policy_objects = [for f in local.org_policy_config_files : yamldecode(file("config/org-policy/sw-unified-data-paltform${f}"))]
  org_policies = length(local.org_policy_objects) > 0 ? local.org_policy_objects[0] : { deploy = false, folder_id = "",project_id = "", policy_boolean = {}, policy_list = {} }
}

module "orgpolicy" {
  source                         = "git@github.com:AjitPunchhiInutive/-sw-prod-udp-rds-infra-modules.git//orgpolicy?ref=main"
  org_policies                   = local.org_policies
}

