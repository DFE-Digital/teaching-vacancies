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

resource cloudfoundry_app web_app {
  name                       = local.web_app_name
  command                    = local.web_app_start_command
  docker_image               = var.app_docker_image
  health_check_type          = "http"
  health_check_http_endpoint = "/check"
  instances                  = var.web_app_instances
  memory                     = var.web_app_memory
  routes {
    route = cloudfoundry_route.web_app_route.id
  }
  space    = data.cloudfoundry_space.space.id
  stopped  = var.app_stopped
  strategy = var.web_app_deployment_strategy
  timeout  = var.app_start_timeout
  dynamic "service_binding" {
    for_each = local.app_service_bindings
    content {
      service_instance = service_binding.value
    }
  }
  environment = local.app_environment
}

resource cloudfoundry_route web_app_route {
  domain   = data.cloudfoundry_domain.cloudapps_digital.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.web_app_name
}

resource cloudfoundry_app worker_app {
  name              = local.worker_app_name
  command           = local.worker_app_start_command
  docker_image      = var.app_docker_image
  health_check_type = "process"
  instances         = var.worker_app_instances
  memory            = var.worker_app_memory
  space             = data.cloudfoundry_space.space.id
  stopped           = var.app_stopped
  strategy          = var.worker_app_deployment_strategy
  timeout           = var.app_start_timeout
  dynamic "service_binding" {
    for_each = local.app_service_bindings
    content {
      service_instance = service_binding.value
    }
  }
  environment = local.app_environment
}
