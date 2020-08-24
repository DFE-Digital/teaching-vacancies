variable environment {
}

variable app_docker_image {
}

variable app_env_values {}

variable app_start_timeout {
  default = 300
}

variable app_stopped {
  default = false
}

variable papertrail_url {
}

variable parameter_store_environment {
  default = "dev"
}

variable postgres_service_plan {
}

variable project_name {
}

variable redis_service_plan {
}

variable space_name {
}

variable web_app_deployment_strategy {
}

variable web_app_instances {
  default = 1
}

variable web_app_memory {
  default = 512
}

variable worker_app_deployment_strategy {
}

variable worker_app_instances {
  default = 1
}

variable worker_app_memory {
  default = 512
}

locals {
  app_env_api_keys = merge(
    yamldecode(data.aws_ssm_parameter.app_env_api_key_big_query.value),
    yamldecode(data.aws_ssm_parameter.app_env_api_key_cloud_storage.value),
    yamldecode(data.aws_ssm_parameter.app_env_api_key_google.value)
  )
  app_env_secrets          = yamldecode(data.aws_ssm_parameter.app_env_secrets.value)
  papertrail_service_name  = "${var.project_name}-papertrail-${var.environment}"
  postgres_service_name    = "${var.project_name}-postgres-${var.environment}"
  redis_service_name       = "${var.project_name}-redis-${var.environment}"
  web_app_name             = "${var.project_name}-${var.environment}"
  web_app_start_command    = "bundle exec rake cf:on_first_instance db:migrate && rails s"
  worker_app_start_command = "bundle exec sidekiq -C config/sidekiq.yml"
  worker_app_name          = "${var.project_name}-worker-${var.environment}"
  app_environment = merge(
    local.app_env_api_keys,
    local.app_env_secrets,
    var.app_env_values
  )
}
