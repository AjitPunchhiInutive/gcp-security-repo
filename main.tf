locals {

  # WIF: list from config/wif/*.yaml
  wif_config_files = fileset("config/wif", "*.yaml")
  wif_objects = [for f in local.wif_config_files : yamldecode(file("config/wif/${f}"))]

  # Folders: single object from config/folders.yaml (module expects only organization_id, parent_folders, sub_folders)
  folder_config_files = fileset("config/folders", "*.yaml")
  folders_raw         = length(local.folder_config_files) > 0 ? yamldecode(file("config/folders/folders.yaml")) : null
  folders_objects     = local.folders_raw != null ? { organization_id = local.folders_raw.organization_id, parent_folders = local.folders_raw.parent_folders, sub_folders = local.folders_raw.sub_folders } : { organization_id = var.organization_id, parent_folders = {}, sub_folders = {} }

  
  project_config_files = fileset("config/project-factory", "*.yaml")
  project_objects = [for f in local.project_config_files : yamldecode(file("config/project-factory/${f}"))]
}
  # Projects: list from config/projects/*.yaml
module "wif_factory" {
  source                         = "git@github.com:AjitPunchhiInutive/-sw-prod-udp-rds-infra-modules.git//wif-factory?ref=main"
  github_workload_identity_factory = local.wif_objects
}

  module "folders" {
  source          = "git@github.com:AjitPunchhiInutive/-sw-prod-udp-rds-infra-modules.git//folders?ref=main"
  folders_objects = local.folders_objects
}

module "project-factory" {
  source          = "git@github.com:AjitPunchhiInutive/-sw-prod-udp-rds-infra-modules.git//project-factory?ref=main"
  project_objects = local.project_objects
}
