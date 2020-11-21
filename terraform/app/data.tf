data aws_ssm_parameter infra_secrets {
  name = "/${local.service_name}/${var.parameter_store_environment}/infra/secrets"
}
