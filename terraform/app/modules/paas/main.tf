resource cloudfoundry_service_instance postgres_instance {
  name         = local.postgres_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans["${var.postgres_service_plan}"]
  json_params  = "{\"enable_extensions\": [\"pgcrypto\", \"fuzzystrmatch\", \"plpgsql\"]}"
}

resource cloudfoundry_service_instance redis_instance {
  name         = local.redis_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans["${var.redis_service_plan}"]
}

resource cloudfoundry_user_provided_service papertrail {
  name             = local.papertrail_service_name
  space            = data.cloudfoundry_space.space.id
  syslog_drain_url = var.papertrail_url
}
