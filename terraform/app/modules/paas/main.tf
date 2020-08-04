resource cloudfoundry_service_instance postgres_instance{
  name = local.postgres_service_name
  space = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans["tiny-unencrypted-11"]
  json_params = "{\"enable_extensions\": [\"pgcrypto\", \"fuzzystrmatch\", \"plpgsql\"]}"
}
