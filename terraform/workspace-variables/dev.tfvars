# Platform
region                      = "eu-west-2"
environment                 = "dev"
app_environment             = "dev"
parameter_store_environment = "dev"

# CloudFront
distribution_list = {
  "tvsdev" = {
    offline_bucket_domain_name    = "530003481352-offline-site.s3.amazonaws.com"
    offline_bucket_origin_path    = "/teaching-vacancies-offline"
    cloudfront_origin_domain_name = "teaching-vacancies-dev.london.cloudapps.digital"
  }
}

# Monitoring
channel_list = {
  #   "tvsdev" = {
  #     cloudwatch_slack_channel = "twd_tv_dev"
  #   }
}

# Documents S3 bucket
documents_s3_bucket_force_destroy = false

# Gov.UK PaaS
paas_space_name                     = "teaching-vacancies-dev"
paas_logging_service_binding_enable = false
paas_postgres_service_plan          = "small-11"
paas_redis_cache_service_plan       = "micro-5_x"
paas_redis_queue_service_plan       = "micro-5_x"
paas_app_start_timeout              = "180"
paas_app_stopped                    = false
paas_web_app_deployment_strategy    = "blue-green-v2"
paas_web_app_instances              = 2
paas_worker_app_deployment_strategy = "blue-green-v2"
paas_worker_app_instances           = 2
paas_worker_app_memory              = 512
