data "cloudfoundry_space" "monitoring" {
  name     = local.monitoring_space_name
  org_name = local.monitoring_org_name
}

data "aws_ssm_parameter" "monitoring_secrets" {
  name = "/${local.service_name}/production/infra/monitoring"
}
