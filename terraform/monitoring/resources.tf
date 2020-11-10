module prometheus_all {
  source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/prometheus_all"

  monitoring_instance_name = local.monitoring_instance_name
  monitoring_org_name      = local.monitoring_org_name
  monitoring_space_name    = local.monitoring_space_name
  paas_exporter_username   = var.paas_exporter_username
  paas_exporter_password   = var.paas_exporter_password
  alertmanager_config      = file("${path.module}/files/alertmanager.yml")
  grafana_admin_password   = var.grafana_admin_password
  grafana_json_dashboards  = [file("${path.module}/files/paas_dashboard.json")]
  alert_rules              = file("${path.module}/files/alert.rules")
}
