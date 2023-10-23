data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "app_env_api_key_big_query" {
  name = "/${var.service_name}/${var.parameter_store_environment}/app/BIG_QUERY_API_JSON_KEY"
}

data "aws_ssm_parameter" "app_env_api_key_google" {
  name = "/${var.service_name}/${var.parameter_store_environment}/app/GOOGLE_API_JSON_KEY"
}

data "aws_ssm_parameter" "app_env_secrets" {
  name = "/${var.service_name}/${var.parameter_store_environment}/app/secrets"
}

