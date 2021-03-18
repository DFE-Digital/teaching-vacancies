module "prometheus_all" {
  source = "git::https://github.com/DFE-Digital/cf-monitoring.git//prometheus_all"

  monitoring_instance_name   = local.monitoring_instance_name
  monitoring_org_name        = local.monitoring_org_name
  monitoring_space_name      = local.monitoring_space_name
  paas_exporter_username     = local.secrets["paas_exporter_username"]
  paas_exporter_password     = local.secrets["paas_exporter_password"]
  grafana_admin_password     = local.secrets["grafana_admin_password"]
  grafana_json_dashboards    = [file("${path.module}/config/paas_dashboard.json")]
  alert_rules                = file("${path.module}/config/alert.rules.yml")
  alertmanager_slack_url     = local.alertmanager_slack_url
  alertmanager_slack_channel = local.alertmanager_slack_channel
  redis_service_instance_id  = data.cloudfoundry_service_instance.redis_queue.id
}
