# Platform
region                      = "eu-west-2"
project_name                = "teaching-vacancies"
environment                 = "staging"
parameter_store_environment = "staging"

# CloudFront
cloudfront_distributions = {
  "tvsstaging" = {
    cloudfront_aliases            = ["tvs.staging.dxw.net", "*.tvs.staging.dxw.net"]
    offline_bucket_domain_name    = "tvs-offline.s3.amazonaws.com"
    offline_bucket_origin_path    = "/school-jobs-offline"
    cloudfront_origin_domain_name = "teaching-vacancies-staging.london.cloudapps.digital"
    domain                        = "staging.teaching-vacancies.service.gov.uk"
  }
}

# Monitoring
cloudwatch_slack_channels = {
  "tvsstaging" = {
    cloudwatch_slack_channel = "twd_tv_dev"
  }
}

# Gov.UK PaaS
paas_api_url                           = "https://api.london.cloud.service.gov.uk"
paas_space_name                        = "teaching-vacancies-staging"
paas_papertrail_service_binding_enable = true
paas_postgres_service_plan             = "small-11"
paas_redis_service_plan                = "tiny-4_x"
paas_app_start_timeout                 = "60"
paas_app_stopped                       = false
paas_web_app_deployment_strategy       = "blue-green-v2"
paas_web_app_instances                 = 2
paas_worker_app_deployment_strategy    = "blue-green-v2"
paas_worker_app_instances              = 2
paas_worker_app_memory                 = 512
