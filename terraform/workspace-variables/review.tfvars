# Platform
region                      = "eu-west-2"
project_name                = "teaching-vacancies"
parameter_store_environment = "dev"
#environment                 = "review"  # For review, pass in TV_VAR_environment for the PR number

# CloudFront
cloudfront_distributions = {
  #  "tvsreview" = {
  #    cloudfront_aliases            = ["review.teaching-vacancies.service.gov.uk"]
  #    offline_bucket_domain_name    = "tvs-offline.s3.amazonaws.com"
  #    offline_bucket_origin_path    = "/school-jobs-offline"
  #    cloudfront_origin_domain_name = "teaching-vacancies-review.london.cloudapps.digital"
  #    domain                        = "review.teaching-vacancies.service.gov.uk"
  #  }
}

# CloudWatch
cloudwatch_slack_channels = {
  #   "tvsreview" = {
  #     cloudwatch_slack_channel = "twd_tv_dev"
  #   }
}

# Gov.UK PaaS
paas_api_url                           = "https://api.london.cloud.service.gov.uk"
paas_space_name                        = "teaching-vacancies-review"
paas_postgres_service_plan             = "tiny-unencrypted-11"
paas_redis_service_plan                = "tiny-4_x"
paas_papertrail_service_binding_enable = false
paas_app_start_timeout                 = "60"
paas_app_stopped                       = false
paas_web_app_deployment_strategy       = "blue-green-v2"
paas_web_app_instances                 = 2
paas_worker_app_deployment_strategy    = "blue-green-v2"
paas_worker_app_instances              = 2
paas_worker_app_memory                 = 512
