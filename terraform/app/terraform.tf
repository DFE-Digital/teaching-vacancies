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

module "cloudfront_aks" {
  source                        = "./modules/cloudfront"
  for_each                      = var.distribution_list_aks
  environment                   = var.environment
  enable_cloudfront_compress    = var.enable_cloudfront_compress
  service_name                  = local.service_name
  cloudfront_origin_domain_name = each.value.cloudfront_origin_domain_name
  offline_bucket_domain_name    = each.value.offline_bucket_domain_name
  offline_bucket_origin_path    = each.value.offline_bucket_origin_path
  route53_zones                 = var.route53_zones
  is_production                 = local.is_production
  route53_a_records             = var.aks_route53_a_records
  route53_cname_record          = var.aks_route53_cname_record
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
  source                                       = "./modules/paas"
  environment                                  = var.environment
  app_docker_image                             = var.app_docker_image
  app_env_values                               = local.app_env_values
  parameter_store_environment                  = var.parameter_store_environment
  service_name                                 = local.service_name
  service_abbreviation                         = local.service_abbreviation
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
  aks_web_app_instances             = var.aks_web_app_instances
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
  web_external_hostnames_aks        = local.web_external_hostnames_aks
}

module "statuscake" {
  source = "./modules/statuscake"

  environment       = var.environment
  service_name      = local.service_name
  statuscake_alerts = var.statuscake_alerts
}
