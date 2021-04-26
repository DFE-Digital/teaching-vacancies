variable "environment" {
}

variable "app_docker_image" {
}

variable "app_env_values" {
}

variable "app_start_timeout" {
  default = 300
}

variable "app_stopped" {
  default = false
}

variable "docker_username" {
}

variable "docker_password" {
}

variable "papertrail_service_binding_enable" {
}

variable "papertrail_url" {
}

variable "parameter_store_environment" {
  default = "dev"
}

variable "postgres_service_plan" {
}

variable "redis_cache_service_plan" {
}
variable "redis_queue_service_plan" {
}

variable "service_name" {
}
variable "space_name" {
}

variable "web_app_deployment_strategy" {
}

variable "web_app_instances" {
  default = 1
}

variable "web_app_memory" {
  default = 512
}

variable "web_app_start_command" {
}

variable "worker_app_deployment_strategy" {
}

variable "worker_app_instances" {
  default = 1
}

variable "worker_app_memory" {
  default = 512
}

variable "route53_zones" {
  type = list(any)
}

variable "route53_a_records" {
  type = list(any)
}

variable "hostname_domain_map" {
  type = map(any)
}

locals {
  app_env_api_keys = merge(
    yamldecode(data.aws_ssm_parameter.app_env_api_key_big_query.value),
    yamldecode(data.aws_ssm_parameter.app_env_api_key_google.value)
  )
  app_env_secrets = yamldecode(data.aws_ssm_parameter.app_env_secrets.value)
  app_env_domain  = { "DOMAIN" = "teaching-vacancies-${var.environment}.london.cloudapps.digital" }
  app_environment = merge(
    local.app_env_api_keys,
    local.app_env_secrets,
    local.app_env_domain,
    var.app_env_values #Because of merge order, if present, the value of DOMAIN in .tfvars will overwrite app_env_domain
  )
  app_cloudfoundry_service_instances = [
    cloudfoundry_service_instance.postgres_instance.id,
    cloudfoundry_service_instance.redis_cache_instance.id,
    cloudfoundry_service_instance.redis_queue_instance.id,
  ]
  app_user_provided_service_bindings = var.papertrail_service_binding_enable ? [cloudfoundry_user_provided_service.papertrail.id] : []
  app_service_bindings = concat(
    local.app_cloudfoundry_service_instances,
    local.app_user_provided_service_bindings
  )
  papertrail_service_name  = "${var.service_name}-papertrail-${var.environment}"
  postgres_service_name    = "${var.service_name}-postgres-${var.environment}"
  redis_cache_service_name = "${var.service_name}-redis-cache-${var.environment}"
  redis_queue_service_name = "${var.service_name}-redis-queue-${var.environment}"
  documents_s3_bucket_name = "${var.service_name}-documents-${var.environment}"
  web_app_name             = "${var.service_name}-${var.environment}"
  worker_app_start_command = "bundle exec sidekiq -C config/sidekiq.yml"
  worker_app_name          = "${var.service_name}-worker-${var.environment}"
}
