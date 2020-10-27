data aws_ssm_parameter app_env_api_key_big_query {
  name = "/tvs/${var.parameter_store_environment}/app/BIG_QUERY_API_JSON_KEY"
}

data aws_ssm_parameter app_env_api_key_google {
  name = "/tvs/${var.parameter_store_environment}/app/GOOGLE_API_JSON_KEY"
}

data aws_ssm_parameter app_env_secrets {
  name = "/tvs/${var.parameter_store_environment}/app/secrets"
}

data cloudfoundry_org org {
  name = "dfe-teacher-services"
}

data cloudfoundry_space space {
  name = var.space_name
  org  = data.cloudfoundry_org.org.id
}

data cloudfoundry_domain cloudapps_digital {
  name = "london.cloudapps.digital"
}

data cloudfoundry_domain cloudfront {
  for_each = toset(var.route53_zones)
  name     = each.key
}

data cloudfoundry_service postgres {
  name = "postgres"
}

data cloudfoundry_service redis {
  name = "redis"
}
