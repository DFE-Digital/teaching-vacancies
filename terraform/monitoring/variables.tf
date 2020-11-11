variable paas_sso_passcode { default = null }
variable paas_username { default = null }
variable paas_password { default = null }

locals {
  monitoring_instance_name = "teaching-vacancies"
  paas_api_url             = "https://api.london.cloud.service.gov.uk"
  monitoring_org_name      = "dfe-teacher-services"
  space_name               = "teaching-vacancies-monitoring"
  monitoring_space_name    = "teaching-vacancies-monitoring"
  aws_region               = "eu-west-2"
  secrets                  = yamldecode(data.aws_ssm_parameter.monitoring_secrets.value)
}
