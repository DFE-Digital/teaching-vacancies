module "prometheus_all" {
  source = "git::https://github.com/DFE-Digital/cf-monitoring.git//prometheus_all"

  monitoring_instance_name     = local.monitoring_instance_name
  monitoring_org_name          = local.monitoring_org_name
  monitoring_space_name        = local.monitoring_space_name
  paas_exporter_username       = local.secrets["paas_exporter_username"]
  paas_exporter_password       = local.secrets["paas_exporter_password"]
  grafana_admin_password       = local.secrets["grafana_admin_password"]
  grafana_json_dashboards      = local.grafana_dashboard_strings
  alert_rules                  = file("${path.module}/config/alert.rules.yml")
  alertmanager_slack_url       = local.alertmanager_slack_url
  alertmanager_slack_channel   = local.alertmanager_slack_channel
  grafana_google_client_id     = local.secrets.grafana_google_client_id
  grafana_google_client_secret = local.secrets.grafana_google_client_secret
  grafana_anonymous_auth       = true
  enable_prometheus_yearly     = true
  redis_services = [
    "${local.service_name}-production/${local.service_name}-redis-queue-production",
    "${local.service_name}-production/${local.service_name}-redis-cache-production",
    "${local.service_name}-staging/${local.service_name}-redis-queue-staging",
    "${local.service_name}-staging/${local.service_name}-redis-cache-staging"
  ]
}
