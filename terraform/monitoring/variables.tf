variable "paas_sso_passcode" { default = null }
variable "paas_user" { default = null }
variable "paas_password" { default = null }

locals {
  service_name               = "teaching-vacancies"
  monitoring_instance_name   = local.service_name
  paas_api_url               = "https://api.london.cloud.service.gov.uk"
  monitoring_org_name        = "dfe"
  space_name                 = "${local.service_name}-monitoring"
  monitoring_space_name      = "${local.service_name}-monitoring"
  service_space_name         = "${local.service_name}-production"
  redis_queue_name           = "${local.service_name}-redis-queue-production"
  aws_region                 = "eu-west-2"
  secrets                    = yamldecode(data.aws_ssm_parameter.monitoring_secrets.value)
  alertmanager_slack_url     = local.secrets["alertmanager_slack_url"]
  alertmanager_slack_channel = "twd_tv_dev"
}
