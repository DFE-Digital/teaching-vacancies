module "postgres" {
  source = "./vendor/modules/aks//aks/postgres"

  namespace                   = var.namespace
  environment                 = var.environment
  azure_resource_prefix       = var.azure_resource_prefix
  service_name                = var.service_name
  service_short               = var.service_short
  config_short                = var.config_short
  cluster_configuration_map   = module.cluster_data.configuration_map
  use_azure                   = var.deploy_azure_backing_services
  azure_enable_backup_storage = var.azure_enable_backup_storage
}
