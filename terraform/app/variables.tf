variable project_name {
  description = "This name will be used to identify all AWS resources. The workspace name will be suffixed. Alphanumeric characters only due to RDS."
}

variable region {
  default = "eu-west-2"
}

variable environment {}

# CloudFront

variable distribution_list {
  description = "Define Cloudfront distributions with the attributes below"
  type = map(object({
    offline_bucket_domain_name      = string
    offline_bucket_origin_path      = string
    cloudfront_origin_domain_name   = string
    cloudfront_enable_standard_logs = bool
  }))
  default = {}
}

variable route53_zones {
  type    = list
  default = ["teaching-jobs.service.gov.uk", "teaching-vacancies.service.gov.uk"]
}

# CloudWatch
variable channel_list {
  description = "Define slack channels CloudWatch should send alerts to"
  type = map(object({
    cloudwatch_slack_channel = string
  }))
  default = {}
}

# Gov.UK PaaS
variable paas_api_url {
}

variable paas_password {
  default = ""
}

variable paas_app_docker_image {}

variable paas_app_start_timeout {
  default = 300
}

variable paas_app_stopped {
  default = false
}

variable app_environment {
  default = "dev"
}

variable parameter_store_environment {
  default = "dev"
}

variable paas_papertrail_service_binding_enable {
  default = true
}

variable paas_postgres_service_plan {
  default = "tiny-unencrypted-11"
}

variable paas_redis_service_plan {
  default = "tiny-4_x"
}

variable paas_space_name {
}

variable paas_sso_passcode {
  default = ""
}

variable paas_store_tokens_path {
  default = ""
}

variable paas_user {
  default = ""
}

variable paas_web_app_deployment_strategy {
  default = "blue-green-v2"
}

variable paas_web_app_instances {
  default = 1
}

variable paas_web_app_memory {
  default = 512
}

variable paas_web_app_start_command {
  default = "bundle exec rake cf:on_first_instance db:migrate && rails s"
}

variable paas_worker_app_deployment_strategy {
  default = "blue-green-v2"
}

variable paas_worker_app_instances {
  default = 1
}

variable paas_worker_app_memory {
  default = 512
}

# Statuscake
variable statuscake_alerts {
  description = "Define Statuscake alerts with the attributes below"
  type = map(object({
    website_name  = string
    website_url   = string
    test_type     = string
    check_rate    = string
    contact_group = list(string)
    trigger_rate  = string
    custom_header = string
    status_codes  = string
  }))
  default = {}
}

locals {
  paas_app_env_values  = yamldecode(file("${path.module}/../workspace-variables/${var.app_environment}_app_env.yml"))
  infra_secrets        = yamldecode(data.aws_ssm_parameter.infra_secrets.value)
  is_production        = var.environment == "production"
  route53_a_records    = local.is_production ? var.route53_zones : []
  route53_cname_record = local.is_production ? "www" : var.environment
  hostname_domain_map = {
    for zone in var.route53_zones :
    "${local.route53_cname_record}.${zone}" => {
      hostname = local.route53_cname_record
      domain   = zone
    }
  }
}
