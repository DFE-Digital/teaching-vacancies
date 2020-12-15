module prometheus_all {
  source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/prometheus_all?ref=teva-859-add-slack-to-prometheus-all"

  monitoring_instance_name   = local.monitoring_instance_name
  monitoring_org_name        = local.monitoring_org_name
  monitoring_space_name      = local.monitoring_space_name
  paas_exporter_username     = local.secrets["paas_exporter_username"]
  paas_exporter_password     = local.secrets["paas_exporter_password"]
  alertmanager_config        = templatefile("${path.module}/config/alertmanager.yml.tmpl", local.alertmanager_variables)
  grafana_admin_password     = local.secrets["grafana_admin_password"]
  grafana_json_dashboards    = [file("${path.module}/config/paas_dashboard.json")]
  alert_rules                = file("${path.module}/config/alert.rules")
}

# alert_rules are to configure the alerts within Prometheus
