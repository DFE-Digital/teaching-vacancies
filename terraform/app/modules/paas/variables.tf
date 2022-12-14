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

variable "logging_service_binding_enable" {
}

variable "logging_url" {
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

variable "documents_s3_bucket_force_destroy" {
  default = false
}

variable "schools_images_logos_s3_bucket_force_destroy" {
  default = false
}

variable "service_name" {
}
variable "service_abbreviation" {
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

variable "restore_from_db_guid" {

}

variable "db_backup_before_point_in_time" {

}


locals {
  app_env_api_keys = merge(
    yamldecode(data.aws_ssm_parameter.app_env_api_key_big_query.value),
    yamldecode(data.aws_ssm_parameter.app_env_api_key_google.value)
  )
  app_env_secrets = yamldecode(data.aws_ssm_parameter.app_env_secrets.value)
  app_env_documents_bucket_credentials = {
    DOCUMENTS_S3_BUCKET         = local.documents_s3_bucket_name
    DOCUMENTS_ACCESS_KEY_ID     = aws_iam_access_key.documents_s3_bucket_access_key.id
    DOCUMENTS_ACCESS_KEY_SECRET = aws_iam_access_key.documents_s3_bucket_access_key.secret
  }
  app_env_schools_images_logos_s3_bucket_credentials = {
    SCHOOLS_IMAGES_LOGOS_S3_BUCKET         = local.schools_images_logos_s3_bucket_name
    SCHOOLS_IMAGES_LOGOS_ACCESS_KEY_ID     = aws_iam_access_key.schools_images_logos_s3_bucket_access_key.id
    SCHOOLS_IMAGES_LOGOS_ACCESS_KEY_SECRET = aws_iam_access_key.schools_images_logos_s3_bucket_access_key.secret
  }
  app_env_domain = { "DOMAIN" = "teaching-vacancies-${var.environment}.london.cloudapps.digital" }
  app_environment = merge(
    local.app_env_api_keys,
    local.app_env_secrets,
    local.app_env_documents_bucket_credentials,
    local.app_env_schools_images_logos_s3_bucket_credentials,
    local.app_env_domain,
    local.postgres_instance_service_key,
    var.app_env_values #Because of merge order, if present, the value of DOMAIN in .tfvars.json will overwrite app_env_domain
  )
  app_cloudfoundry_service_instances = [
    cloudfoundry_service_instance.redis_cache_instance.id,
    cloudfoundry_service_instance.redis_queue_instance.id,
  ]

  postgres_instance_service_key = { DATABASE_URL = cloudfoundry_service_key.postgres_instance_service_key.credentials.uri }

  app_user_provided_service_bindings = var.logging_service_binding_enable ? [cloudfoundry_user_provided_service.logging.id] : []
  app_service_bindings               = concat(local.app_cloudfoundry_service_instances, local.app_user_provided_service_bindings)
  logging_service_name               = "${var.service_name}-logging-${var.environment}"
  postgres_service_name              = "${var.service_name}-postgres-${var.environment}"
  redis_cache_service_name           = "${var.service_name}-redis-cache-${var.environment}"
  redis_queue_service_name           = "${var.service_name}-redis-queue-${var.environment}"
  # S3 bucket name uses abbreviation so we don't run into 63 character bucket name limit
  documents_s3_bucket_name            = "${data.aws_caller_identity.current.account_id}-${var.service_abbreviation}-attachments-documents-${var.environment}"
  schools_images_logos_s3_bucket_name = "${data.aws_caller_identity.current.account_id}-${var.service_abbreviation}-attachments-images-logos-${var.environment}"
  web_app_name                        = "${var.service_name}-${var.environment}"
  worker_app_start_command            = "bundle exec sidekiq -C config/sidekiq.yml"
  worker_app_name                     = "${var.service_name}-worker-${var.environment}"

  postgres_backup_restore_params = var.restore_from_db_guid != "" ? {
    restore_from_point_in_time_of     = var.restore_from_db_guid
    restore_from_point_in_time_before = var.db_backup_before_point_in_time
  } : {}
  postgres_extensions  = { enable_extensions = ["pgcrypto", "fuzzystrmatch", "plpgsql", "pg_trgm", "postgis"] }
  postgres_json_params = merge(local.postgres_backup_restore_params, local.postgres_extensions)


}
