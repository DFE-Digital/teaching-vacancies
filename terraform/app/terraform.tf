provider aws {
  region = var.region
}

/*
For username / password authentication:
- user
- password
For SSO authentication
- sso_passcode
- store_tokens_path = /path/to/local/file
*/

provider cloudfoundry {
  api_url           = var.paas_api_url
  password          = var.paas_password != "" ? var.paas_password : null
  sso_passcode      = var.paas_sso_passcode != "" ? var.paas_sso_passcode : null
  store_tokens_path = "./tokens"
  user              = var.paas_user != "" ? var.paas_user : null

}

provider statuscake {
  username = local.infra_secrets.statuscake_username
  apikey   = local.infra_secrets.statuscake_apikey
}

provider template {}

/*
Store infrastructure state in a remote store (instead of local machine):
https://www.terraform.io/docs/state/purpose.html
*/
terraform {

  backend "s3" {
    bucket  = "terraform-state-002"
    key     = "tvs/terraform.tfstate" # When using workspaces this changes to ':env/{terraform.workspace}/tvs/terraform.tfstate'
    region  = "eu-west-2"
    encrypt = "true"
  }
}


module cloudfront {
  source                        = "./modules/cloudfront"
  for_each                      = var.cloudfront_distributions
  environment                   = var.environment
  project_name                  = var.project_name
  cloudfront_origin_domain_name = each.value.cloudfront_origin_domain_name
  cloudfront_aliases            = each.value.cloudfront_aliases
  cloudfront_certificate_arn    = local.infra_secrets.cloudfront_certificate_arn
  offline_bucket_domain_name    = each.value.offline_bucket_domain_name
  offline_bucket_origin_path    = each.value.offline_bucket_origin_path
  domain                        = each.value.domain
}

module cloudwatch {
  source            = "./modules/cloudwatch"
  for_each          = var.cloudwatch_slack_channels
  environment       = var.environment
  project_name      = var.project_name
  slack_hook_url    = local.infra_secrets.cloudwatch_slack_hook_url
  slack_channel     = each.value.cloudwatch_slack_channel
  ops_genie_api_key = local.infra_secrets.cloudwatch_ops_genie_api_key
}

module paas {
  source = "./modules/paas"

  environment                       = var.environment
  app_docker_image                  = var.paas_app_docker_image
  app_env_values                    = local.paas_app_env_values
  app_start_timeout                 = var.paas_app_start_timeout
  app_stopped                       = var.paas_app_stopped
  papertrail_url                    = local.infra_secrets.papertrail_url
  papertrail_service_binding_enable = var.paas_papertrail_service_binding_enable
  parameter_store_environment       = var.parameter_store_environment
  project_name                      = var.project_name
  postgres_service_plan             = var.paas_postgres_service_plan
  redis_service_plan                = var.paas_redis_service_plan
  space_name                        = var.paas_space_name
  web_app_deployment_strategy       = var.paas_web_app_deployment_strategy
  web_app_instances                 = var.paas_web_app_instances
  web_app_memory                    = var.paas_web_app_memory
  worker_app_deployment_strategy    = var.paas_worker_app_deployment_strategy
  worker_app_instances              = var.paas_worker_app_instances
  worker_app_memory                 = var.paas_worker_app_memory

}

module statuscake {
  source = "./modules/statuscake"

  environment       = var.environment
  project_name      = var.project_name
  statuscake_alerts = var.statuscake_alerts
}
