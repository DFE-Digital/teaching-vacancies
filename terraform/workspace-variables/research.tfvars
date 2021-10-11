# Platform
region                      = "eu-west-2"
parameter_store_environment = "research"
app_environment             = "research"
environment                 = "research" # For review, pass in TF_VAR_environment=review-pr-[PR number]

# CloudFront
distribution_list = {
  "tvsresearch" = {
    offline_bucket_domain_name    = "530003481352-offline-site.s3.amazonaws.com"
    offline_bucket_origin_path    = "/teaching-vacancies-offline"
    cloudfront_origin_domain_name = "teaching-vacancies-research.london.cloudapps.digital"
  }
}

# Documents S3 bucket
documents_s3_bucket_force_destroy = true

# Gov.UK PaaS
paas_space_name                     = "teaching-vacancies-dev"
paas_logging_service_binding_enable = false
paas_app_start_timeout              = "180"
paas_web_app_instances              = 2
paas_worker_app_instances           = 2
