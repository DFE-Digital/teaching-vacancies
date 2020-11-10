variable paas_sso_passcode { default = "" }
variable paas_store_tokens_path { default = "" }
variable paas_username { default = "" }
variable paas_password { default = "" }

variable paas_exporter_username {}
variable paas_exporter_password {}
variable grafana_admin_password {}

locals {
  monitoring_instance_name = "teaching-vacancies"
  paas_api_url             = "https://api.london.cloud.service.gov.uk"
  monitoring_org_name      = "dfe-teacher-services"
  space_name               = "teaching-vacancies-monitoring"
  monitoring_space_name    = "teaching-vacancies-monitoring"
}
