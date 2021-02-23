resource "cloudfoundry_service_instance" "postgres_instance" {
  name         = local.postgres_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_service_plan]
  json_params  = "{\"enable_extensions\": [\"pgcrypto\", \"fuzzystrmatch\", \"plpgsql\"]}"
}

resource "cloudfoundry_service_instance" "redis_cache_instance" {
  name         = local.redis_cache_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.redis_cache_service_plan]
  json_params  = "{\"maxmemory_policy\": \"allkeys-lru\"}"
}

resource "cloudfoundry_service_instance" "redis_queue_instance" {
  name         = local.redis_queue_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.redis_queue_service_plan]
  json_params  = "{\"maxmemory_policy\": \"noeviction\"}"
}

resource "cloudfoundry_user_provided_service" "papertrail" {
  name             = local.papertrail_service_name
  space            = data.cloudfoundry_space.space.id
  syslog_drain_url = var.papertrail_url
}

resource "cloudfoundry_app" "web_app" {
  name                       = local.web_app_name
  command                    = var.web_app_start_command
  docker_image               = var.app_docker_image
  health_check_type          = "http"
  health_check_http_endpoint = "/check"
  health_check_timeout       = 60
  instances                  = var.web_app_instances
  memory                     = var.web_app_memory
  routes {
    route = cloudfoundry_route.web_app_route.id
  }
  dynamic "routes" {
    for_each = cloudfoundry_route.web_app_route_cloudfront_apex
    content {
      route = routes.value["id"]
    }
  }
  dynamic "routes" {
    for_each = cloudfoundry_route.web_app_route_cloudfront_subdomain
    content {
      route = routes.value["id"]
    }
  }
  docker_credentials = {
    username = var.docker_username
    password = var.docker_password
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

resource "cloudfoundry_route" "web_app_route" {
  domain   = data.cloudfoundry_domain.cloudapps_digital.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.web_app_name
}

resource "cloudfoundry_route" "web_app_route_cloudfront_apex" {
  for_each = toset(var.route53_a_records)
  domain   = data.cloudfoundry_domain.cloudfront[each.key].id
  space    = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_route" "web_app_route_cloudfront_subdomain" {
  for_each = var.hostname_domain_map
  domain   = data.cloudfoundry_domain.cloudfront[each.value["domain"]].id
  space    = data.cloudfoundry_space.space.id
  hostname = each.value["hostname"]
}

resource "cloudfoundry_app" "worker_app" {
  name                 = local.worker_app_name
  command              = local.worker_app_start_command
  docker_image         = var.app_docker_image
  health_check_type    = "process"
  health_check_timeout = 10
  instances            = var.worker_app_instances
  memory               = var.worker_app_memory
  space                = data.cloudfoundry_space.space.id
  stopped              = var.app_stopped
  strategy             = var.worker_app_deployment_strategy
  timeout              = var.app_start_timeout
  dynamic "service_binding" {
    for_each = local.app_service_bindings
    content {
      service_instance = service_binding.value
    }
  }
  docker_credentials = {
    username = var.docker_username
    password = var.docker_password
  }
  environment = local.app_environment
}
