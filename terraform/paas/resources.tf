locals {
  app_deployment_strategy = "blue-green-v2"
  web_app_runs_on_port = 3000
  web_app_start_command = "bundle exec rake cf:on_first_instance db:migrate && rails s"
  worker_app_start_command = "bundle exec sidekiq -C config/sidekiq.yml"
  papertrail_url = "syslog-tls://logs5.papertrailapp.com:47891"
}

resource cloudfoundry_service_instance postgres_instance{
  name = var.postgres_service_name
  space = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans["tiny-unencrypted-11"]
  json_params = "{\"enable_extensions\": [\"pgcrypto\", \"fuzzystrmatch\", \"plpgsql\"]}"
  recursive_delete = var.service_recursive_delete
}

resource cloudfoundry_service_instance redis_instance{
  name = var.redis_service_name
  space = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans["tiny-4_x"]
}

resource cloudfoundry_user_provided_service papertrail {
  name = var.papertrail_service_name
  space = data.cloudfoundry_space.space.id
  syslog_drain_url = local.papertrail_url
}

resource cloudfoundry_app worker_app{
  name = var.worker_app_name
  space = data.cloudfoundry_space.space.id
  stopped = var.app_stopped
  instances = var.no_of_instances
  memory = var.app_memory
  timeout = var.app_start_timeout
  command = local.worker_app_start_command
  docker_image = var.app_docker_image
  strategy = local.app_deployment_strategy
  health_check_type = "process"
  service_binding {
    service_instance = cloudfoundry_service_instance.postgres_instance.id
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.redis_instance.id
  }
  service_binding {
    service_instance = cloudfoundry_user_provided_service.papertrail.id
  }
}

resource cloudfoundry_app web_app{
  name = var.web_app_name
  space = data.cloudfoundry_space.space.id
  stopped = var.app_stopped
  instances = var.no_of_instances
  memory = var.app_memory
  timeout = var.app_start_timeout
  command = local.web_app_start_command
  docker_image = var.app_docker_image
  strategy = local.app_deployment_strategy
  service_binding {
    service_instance = cloudfoundry_service_instance.postgres_instance.id
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.redis_instance.id
  }
  service_binding {
    service_instance = cloudfoundry_user_provided_service.papertrail.id
  }
}

resource cloudfoundry_route web_app_route {
    domain = data.cloudfoundry_domain.cloudapps_digital.id
    space = data.cloudfoundry_space.space.id
    hostname =  var.web_app_name
    target  {    
      app = cloudfoundry_app.web_app.id
    }
}
