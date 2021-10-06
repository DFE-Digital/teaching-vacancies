# Platform
region                      = "eu-west-2"
environment                 = "production"
app_environment             = "production"
parameter_store_environment = "production"

# CloudFront
distribution_list = {
  "tvsprod" = {
    offline_bucket_domain_name    = "530003481352-offline-site.s3.amazonaws.com"
    offline_bucket_origin_path    = "/teaching-vacancies-offline"
    cloudfront_origin_domain_name = "teaching-vacancies-production.london.cloudapps.digital"
  }
}

# Monitoring
channel_list = {
  "tvsprod" = {
    cloudwatch_slack_channel = "twd_tv_dev"
  }
}

# Documents S3 bucket
documents_s3_bucket_force_destroy = false

# Gov.UK PaaS
paas_space_name                     = "teaching-vacancies-production"
paas_logit_service_binding_enable   = true
paas_postgres_service_plan          = "medium-ha-12"
paas_redis_cache_service_plan       = "small-ha-5_x"
paas_redis_queue_service_plan       = "micro-ha-5_x"
paas_app_start_timeout              = "180"
paas_app_stopped                    = false
paas_web_app_deployment_strategy    = "blue-green-v2"
paas_web_app_instances              = 4
paas_worker_app_deployment_strategy = "blue-green-v2"
paas_worker_app_instances           = 2
paas_worker_app_memory              = 1536
paas_web_app_memory                 = 1536

# StatusCake

statuscake_alerts = {
  "tvsprod" = {
    website_name  = "Teaching Vacancies - /check"
    website_url   = "https://teaching-vacancies.service.gov.uk/check"
    contact_group = [183741]
  }
  "stringmatch" = {
    website_name  = "Teaching Vacancies - homepage string"
    website_url   = "https://teaching-vacancies.service.gov.uk"
    contact_group = [183741]
    find_string   = "create an account"
  }
  "PaaS500String" = {
    website_name  = "Teaching Vacancies - PaaS 500 error"
    website_url   = "https://teaching-vacancies.service.gov.uk"
    contact_group = [183741]
    find_string   = "500 Internal Server Error"
    do_not_find   = true
  }
}
