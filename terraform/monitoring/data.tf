data "cloudfoundry_space" "monitoring" {
  name     = local.monitoring_space_name
  org_name = local.monitoring_org_name
}

data "cloudfoundry_space" "service" {
  name     = local.service_space_name
  org_name = local.monitoring_org_name
}
data "cloudfoundry_service_instance" "redis_queue" {
  name_or_id = local.redis_queue_name
  space      = data.cloudfoundry_space.service.id
}

data "aws_ssm_parameter" "monitoring_secrets" {
  name = "/${local.service_name}/production/infra/monitoring"
}
