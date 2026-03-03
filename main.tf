locals {
  org_policy_config_files = fileset("config/org-policy", "*/*.yaml")

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
```

**What changed:**
- Removed `org_policy_objects` (the intermediate list)
- `active_org_policies` is now a **map** keyed by filename (e.g. `"sw-unified-data-platform/sw-unified-data-platform-folder.yaml"`) instead of numeric index
- `for_each` uses the map directly — no more `"0"`, `"1"` keys

This matches exactly what's already in your state:
```
module.orgpolicy["sw-unified-data-platform/sw-unified-data-platform-folder.yaml"]
module.orgpolicy["sw-ent-networking/sw-ent-networking-folder.yaml"]