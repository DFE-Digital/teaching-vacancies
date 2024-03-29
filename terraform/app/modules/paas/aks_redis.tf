
module "redis-cache" {
  source = "../../vendor/modules/aks//aks/redis"

  namespace                 = var.namespace
  environment               = var.environment
  azure_resource_prefix     = var.azure_resource_prefix
  service_short             = var.service_short
  config_short              = var.config_short
  service_name              = var.service_name
  name                      = "cache"
  cluster_configuration_map = module.cluster_data.configuration_map
  use_azure                 = var.deploy_azure_backing_services
  azure_enable_monitoring   = var.enable_monitoring
  azure_patch_schedule      = [{ "day_of_week" : "Sunday", "start_hour_utc" : 01 }]
  azure_maxmemory_policy    = "allkeys-lru"
  server_version            = 6
  azure_capacity            = var.redis_cache_capacity
  azure_family              = var.redis_cache_family
  azure_sku_name            = var.redis_cache_sku_name
}

module "redis-queue" {
  source = "../../vendor/modules/aks//aks/redis"

  namespace                 = var.namespace
  environment               = var.environment
  azure_resource_prefix     = var.azure_resource_prefix
  service_short             = var.service_short
  config_short              = var.config_short
  service_name              = var.service_name
  name                      = "queue"
  cluster_configuration_map = module.cluster_data.configuration_map
  use_azure                 = var.deploy_azure_backing_services
  azure_enable_monitoring   = var.enable_monitoring
  azure_patch_schedule      = [{ "day_of_week" : "Sunday", "start_hour_utc" : 01 }]
  azure_maxmemory_policy    = "noeviction"
  server_version            = 6
  azure_capacity            = var.redis_queue_capacity
  azure_family              = var.redis_queue_family
  azure_sku_name            = var.redis_queue_sku_name
}
