module prometheus_all {
  source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/prometheus_all"

  name                    = var.name
  space_id                = data.cloudfoundry_space.monitoring.id
  paas_exporter_username  = var.paas_exporter_username
  paas_exporter_password  = var.paas_exporter_password
  alertmanager_config     = file("${path.module}/files/alertmanager.yml")
  grafana_admin_password  = var.grafana_admin_password
  grafana_json_dashboards = [file("${path.module}/files/paas_dashboard.json")]
  alert_rules             = file("${path.module}/files/alert.rules")
}
