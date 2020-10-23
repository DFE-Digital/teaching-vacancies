# Platform
region                      = "eu-west-2"
project_name                = "teaching-vacancies"
environment                 = "production"
app_environment             = "production"
parameter_store_environment = "production"

# CloudFront
distribution_list = {
  "tvsprod" = {
    offline_bucket_domain_name      = "tvs-offline.s3.amazonaws.com"
    offline_bucket_origin_path      = "/school-jobs-offline"
    cloudfront_origin_domain_name   = "teaching-vacancies-production.london.cloudapps.digital"
    cloudfront_enable_standard_logs = true
  }
}

# Monitoring
channel_list = {
  "tvsprod" = {
    cloudwatch_slack_channel = "twd_tv_dev"
  }
}

# Gov.UK PaaS
paas_api_url                           = "https://api.london.cloud.service.gov.uk"
paas_space_name                        = "teaching-vacancies-production"
paas_papertrail_service_binding_enable = true
paas_postgres_service_plan             = "medium-ha-11"
paas_redis_service_plan                = "small-ha-4_x"
paas_app_start_timeout                 = "180"
paas_app_stopped                       = false
paas_web_app_deployment_strategy       = "blue-green-v2"
paas_web_app_instances                 = 4
paas_worker_app_deployment_strategy    = "blue-green-v2"
paas_worker_app_instances              = 2
paas_worker_app_memory                 = 1536

# StatusCake

statuscake_alerts = {
  "tvsprod" = {
    website_name  = "teaching-vacancies-production"
    website_url   = "https://teaching-vacancies.service.gov.uk/check"
    test_type     = "HTTP"
    check_rate    = "30"
    contact_group = [183741]
    trigger_rate  = "0"
    custom_header = "{\"Content-Type\": \"application/x-www-form-urlencoded\"}"
    status_codes  = "204,205,206,303,400,401,403,404,405,406,408,410,413,444,429,494,495,496,499,500,501,502,503,504,505,506,507,508,509,510,511,521,522,523,524,520,598,599"
  }
}
