# Platform
region                      = "eu-west-2"
environment                 = "staging"
app_environment             = "staging"
parameter_store_environment = "staging"

# CloudFront
distribution_list = {
  "tvsstaging" = {
    offline_bucket_domain_name    = "530003481352-offline-site.s3.amazonaws.com"
    offline_bucket_origin_path    = "/teaching-vacancies-offline"
    cloudfront_origin_domain_name = "teaching-vacancies-staging.london.cloudapps.digital"
  }
}

# Monitoring
channel_list = {
  "tvsstaging" = {
    cloudwatch_slack_channel = "twd_tv_dev"
  }
}

# Documents S3 bucket
documents_s3_bucket_force_destroy = false

# Gov.UK PaaS
paas_space_name                     = "teaching-vacancies-staging"
paas_logit_service_binding_enable   = true
paas_postgres_service_plan          = "small-12"
paas_redis_cache_service_plan       = "micro-5_x"
paas_redis_queue_service_plan       = "micro-5_x"
paas_app_start_timeout              = "180"
paas_app_stopped                    = false
paas_web_app_deployment_strategy    = "blue-green-v2"
paas_web_app_instances              = 2
paas_worker_app_deployment_strategy = "blue-green-v2"
paas_worker_app_instances           = 2
paas_worker_app_memory              = 512
