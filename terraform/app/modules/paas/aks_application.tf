module "application_configuration" {
  source = "../../vendor/modules/aks//aks/application_configuration"

  namespace              = var.namespace
  environment            = var.environment
  azure_resource_prefix  = var.azure_resource_prefix
  service_short          = var.service_short
  config_short           = var.config_short
  secret_key_vault_short = "app"

  is_rails_application = true

  config_variables = merge(
    var.app_env_values,
    {
      ENVIRONMENT_NAME = var.environment
      PGSSLMODE        = local.postgres_ssl_mode
      DOMAIN           = local.web_app_domain
    },
    local.dfe_sign_in_map,
    local.disable_emails_map,
    local.disable_analytics_map
  )
  secret_variables = merge({
    REDIS_URL    = module.redis-cache.url
    DATABASE_URL = module.postgres.url
    },
    local.app_env_api_keys,
    local.app_env_secrets,
    local.app_env_documents_bucket_credentials,
    local.app_env_schools_images_logos_s3_bucket_credentials
  )
}

module "web_application" {
  source = "../../vendor/modules/aks//aks/application"

  is_web = true

  namespace    = var.namespace
  environment  = var.environment
  service_name = var.service_name

  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image           = var.app_docker_image
  command                = var.aks_web_app_start_command
  probe_path             = "/check"
  web_external_hostnames = var.web_external_hostnames_aks
  replicas               = var.aks_web_app_instances
  enable_logit           = var.enable_logit
  max_memory             = var.aks_web_app_memory
}

module "worker_application" {
  source = "../../vendor/modules/aks//aks/application"

  name   = "worker"
  is_web = false

  namespace    = var.namespace
  environment  = var.environment
  service_name = var.service_name

  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image = var.app_docker_image
  command      = ["/bin/sh", "-c", "bundle exec sidekiq -C config/sidekiq.yml"]
  max_memory   = var.aks_worker_app_memory
  replicas     = var.aks_worker_app_instances
  enable_logit = var.enable_logit
}
