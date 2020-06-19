variable org {
  default = "dfe-teacher-services"
}
variable space {
  default = "teaching-vacancies-monitoring"
}
variable paas_exporter_username {}
variable paas_exporter_password {}
variable name {
  default = "teaching-vacancies"
}
variable paas_username {}
variable paas_password {
  default = ""
}
variable sso_passcode {
  default = ""
}
variable grafana_admin_password {}

locals {
  paas_api_url = "https://api.london.cloud.service.gov.uk"
}
