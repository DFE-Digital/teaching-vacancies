data "aws_ssm_parameter" "monitoring_secrets" {
  name = "/${local.service_name}/production/infra/monitoring"
}
