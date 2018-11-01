variable "environment" {}
variable "project_name" {}
variable "region" {}
variable "ecs_cluster_name" {}
variable "aws_alb_target_group_arn" {}

# Web service (running Puma)
variable "ecs_service_web_container_definition_file_path" {}

variable "ecs_service_web_name" {}
variable "ecs_service_web_task_name" {}
variable "ecs_service_web_task_count" {}
variable "ecs_service_web_task_port" {}

# Worker service (running Sidekiq)
variable "ecs_service_worker_container_definition_file_path" {}

variable "ecs_service_worker_name" {}
variable "ecs_service_worker_task_name" {}
variable "ecs_service_worker_task_port" {}

# Rake task container definitions
variable "ecs_service_rake_container_definition_file_path" {}

variable "performance_platform_rake_container_definition_file_path" {}
variable "google_api_rake_container_definition_file_path" {}

variable "aws_cloudwatch_log_group_name" {}

variable "rails_env" {}
variable "override_school_urn" {}
variable "http_user" {}
variable "http_pass" {}
variable "dfe_sign_in_issuer" {}
variable "dfe_sign_in_redirect_url" {}
variable "dfe_sign_in_identifier" {}
variable "dfe_sign_in_secret" {}
variable "google_maps_api_key" {}
variable "google_analytics" {}
variable "rollbar_access_token" {}
variable "pp_transactions_by_channel_token" {}
variable "pp_user_satisfaction_token" {}
variable "secret_key_base" {}
variable "rds_username" {}
variable "rds_password" {}
variable "rds_address" {}
variable "es_address" {}
variable "aws_elasticsearch_region" {}
variable "aws_elasticsearch_key" {}
variable "aws_elasticsearch_secret" {}
variable "redis_url" {}
variable "authorisation_service_url" {}
variable "authorisation_service_token" {}
variable "google_drive_json_key" {}
variable "auth_spreadsheet_id" {}
variable "published_vacancy_spreadsheet_id" {}
variable "domain" {}
variable "google_geocoding_api_key" {}
variable "google_api_json_key" {
  type = "map"
}
variable "google_analytics_profile_id" {}

variable "ecs_service_logspout_container_definition_file_path" {}

variable "logspout_command" {
  type = "list"
}

variable "ecs_logspout_task_count" {}

variable "worker_command" {
  type = "list"
}

variable "import_schools_task_command" {
  type = "list"
}

variable "sessions_trim_task_command" {
  type = "list"
}

variable "reindex_vacancies_task_command" {
  type = "list"
}

variable "performance_platform_submit_task_command" {
  type = "list"
}

variable "performance_platform_submit_all_task_command" {
  type = "list"
}

variable "sessions_trim_task_schedule" {}
variable "performance_platform_submit_task_schedule" {}
variable "import_schools_task_schedule" {}

variable "vacancies_pageviews_refresh_cache_task_command" {
  type = "list"
}
variable "vacancies_pageviews_refresh_cache_task_schedule" {}
