/*
For username / password authentication:
- user
- password
For SSO authentication
- sso_passcode
- store_tokens_path = /path/to/local/file
*/

provider "cloudfoundry" {
  store_tokens_path = "./tokens"
  api_url           = local.paas_api_url
  user              = var.paas_sso_passcode == "" ? local.infra_secrets.cf_username : null
  password          = var.paas_sso_passcode == "" ? local.infra_secrets.cf_password : null
  sso_passcode      = var.paas_sso_passcode != "" ? var.paas_sso_passcode : null
}

provider "statuscake" {
  api_token = local.infra_secrets.statuscake_apikey
}

/*
Store infrastructure state in a remote store (instead of local machine):
https://www.terraform.io/docs/state/purpose.html
*/
terraform {

  backend "s3" {
    bucket = "530003481352-terraform-state"
    # When run interactively, should prompt for key. To specify environments, we pass to terraform init -backend-config="key=dev/app.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

module "cloudfront" {
  source                        = "./modules/cloudfront"
  for_each                      = var.distribution_list
  environment                   = var.environment
  enable_cloudfront_compress    = var.enable_cloudfront_compress
  service_name                  = local.service_name
  cloudfront_origin_domain_name = each.value.cloudfront_origin_domain_name
  offline_bucket_domain_name    = each.value.offline_bucket_domain_name
  offline_bucket_origin_path    = each.value.offline_bucket_origin_path
  route53_zones                 = var.route53_zones
  is_production                 = local.is_production
  route53_a_records             = local.route53_a_records
  route53_cname_record          = local.route53_cname_record
  providers = {
    aws.aws_us_east_1 = aws.aws_us_east_1
  }
}

module "cloudwatch" {
  source            = "./modules/cloudwatch"
  for_each          = var.channel_list
  environment       = var.environment
  service_name      = local.service_name
  slack_hook_url    = local.infra_secrets.cloudwatch_slack_hook_url
  slack_channel     = each.value.cloudwatch_slack_channel
  ops_genie_api_key = local.infra_secrets.cloudwatch_ops_genie_api_key
}

module "paas" {
  source = "./modules/paas"

  environment                                  = var.environment
  app_docker_image                             = var.paas_app_docker_image
  app_env_values                               = local.paas_app_env_values
  app_start_timeout                            = var.paas_app_start_timeout
  app_stopped                                  = var.paas_app_stopped
  docker_username                              = local.infra_secrets.github_packages_username
  docker_password                              = local.infra_secrets.github_packages_token
  logging_url                                  = local.infra_secrets.logging_url
  logging_service_binding_enable               = var.paas_logging_service_binding_enable
  parameter_store_environment                  = var.parameter_store_environment
  service_name                                 = local.service_name
  service_abbreviation                         = local.service_abbreviation
  postgres_service_plan                        = var.paas_postgres_service_plan
  redis_cache_service_plan                     = var.paas_redis_cache_service_plan
  redis_queue_service_plan                     = var.paas_redis_queue_service_plan
  space_name                                   = var.paas_space_name
  web_app_deployment_strategy                  = var.paas_web_app_deployment_strategy
  web_app_instances                            = var.paas_web_app_instances
  web_app_memory                               = var.paas_web_app_memory
  web_app_start_command                        = var.paas_web_app_start_command
  worker_app_deployment_strategy               = var.paas_worker_app_deployment_strategy
  worker_app_instances                         = var.paas_worker_app_instances
  worker_app_memory                            = var.paas_worker_app_memory
  route53_zones                                = var.route53_zones
  route53_a_records                            = local.route53_a_records
  hostname_domain_map                          = local.hostname_domain_map
  restore_from_db_guid                         = var.paas_restore_from_db_guid
  db_backup_before_point_in_time               = var.paas_db_backup_before_point_in_time
  documents_s3_bucket_force_destroy            = var.documents_s3_bucket_force_destroy
  schools_images_logos_s3_bucket_force_destroy = var.schools_images_logos_s3_bucket_force_destroy
  # AKS
  namespace                         = var.namespace
  azure_resource_prefix             = var.azure_resource_prefix
  config_short                      = var.config_short
  service_short                     = var.service_short
  deploy_azure_backing_services     = var.deploy_azure_backing_services
  enable_monitoring                 = var.enable_monitoring
  cluster                           = var.cluster
  aks_web_app_start_command         = var.aks_web_app_start_command
  aks_worker_app_instances          = var.aks_worker_app_instances
  aks_worker_app_memory             = var.aks_worker_app_memory
  enable_postgres_ssl               = var.enable_postgres_ssl
  postgres_flexible_server_sku      = var.postgres_flexible_server_sku
  postgres_enable_high_availability = var.postgres_enable_high_availability
  redis_cache_capacity              = var.redis_cache_capacity
  redis_cache_family                = var.redis_cache_family
  redis_cache_sku_name              = var.redis_cache_sku_name
  redis_queue_capacity              = var.redis_queue_capacity
  redis_queue_family                = var.redis_queue_family
  redis_queue_sku_name              = var.redis_queue_sku_name
  add_database_name_suffix          = var.add_database_name_suffix
  azure_enable_backup_storage       = var.azure_enable_backup_storage
  statuscake_alerts                 = var.statuscake_alerts
}
module "statuscake" {
  source = "./modules/statuscake"

  environment       = var.environment
  service_name      = local.service_name
  statuscake_alerts = var.statuscake_alerts
}
