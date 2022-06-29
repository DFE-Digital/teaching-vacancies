variable "paas_sso_passcode" { default = null }


locals {
  service_name               = "teaching-vacancies"
  monitoring_instance_name   = local.service_name
  paas_api_url               = "https://api.london.cloud.service.gov.uk"
  monitoring_org_name        = "dfe"
  monitoring_space_name      = "${local.service_name}-monitoring"
  aws_region                 = "eu-west-2"
  secrets                    = yamldecode(data.aws_ssm_parameter.monitoring_secrets.value)
  alertmanager_slack_url     = local.secrets["alertmanager_slack_url"]
  alertmanager_slack_channel = "twd_tv_dev"
  grafana_dashboard_files    = fileset(path.module, "dashboards/*")
  grafana_dashboard_strings  = [for f in local.grafana_dashboard_files : file(f)]
}
