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
variable "rails_max_threads" {}
variable "override_school_urn" {}
variable "http_user" {}
variable "http_pass" {}
variable "dfe_sign_in_issuer" {}
variable "dfe_sign_in_redirect_url" {}
variable "dfe_sign_in_identifier" {}
variable "dfe_sign_in_secret" {}
variable "google_maps_api_key" {}
variable "google_tag_manager_container_id" {}
variable "rollbar_access_token" {}
variable "rollbar_client_errors_access_token" {}
variable "pp_transactions_by_channel_token" {}
variable "secret_key_base" {}
variable "rds_username" {}
variable "rds_password" {}
variable "rds_address" {}
variable "es_address" {}
variable "aws_elasticsearch_region" {}
variable "aws_elasticsearch_key" {}
variable "aws_elasticsearch_secret" {}
variable "redis_cache_url" {}
variable "redis_queue_url" {}

variable "domain" {}
variable "google_geocoding_api_key" {}
variable "ordnance_survey_api_key" {}

variable "google_api_json_key" {
  type = "map"
}

variable "google_analytics_profile_id" {}
variable "skylight_authentication" {}
variable "skylight_env" {}
variable "skylight_enabled" {}
variable "skylight_ignored_endpoints" {}
variable "notify_key" {}
variable "feature_email_alerts" {}
variable "feature_import_vacancies" {}
variable "feature_sign_in_alert" {}
variable "notify_subscription_confirmation_template" {}
variable "notify_subscription_daily_template" {}
variable "notify_prompt_feedback_for_expired_vacancies" {}
variable "subscription_key_generator_secret" {}
variable "subscription_key_generator_salt" {}
variable "dfe_sign_in_url" {}
variable "dfe_sign_in_password" {}
variable "dfe_sign_in_service_access_role_id" {}
variable "dfe_sign_in_service_id" {}
variable "google_cloud_platform_project_id" {}

variable "big_query_api_json_key" {
  type = "map"
}

variable "big_query_dataset" {
  description = "Big Query dataset name"
  type        = "string"
}

variable "cloud_storage_api_json_key" {
  type = "map"
}

variable "cloud_storage_bucket" {
  description = "Cloud Storage Bucket name"
  type        = "string"
}

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

variable "send_job_alerts_daily_email_task_command" {
  type = "list"
}

variable "send_feedback_prompt_email_task_command" {
  type = "list"
}

variable "sessions_trim_task_command" {
  type = "list"
}

variable "reindex_vacancies_task_command" {
  type = "list"
}

variable "seed_vacancies_from_api_task_command" {
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

variable "update_database_records_in_big_query_task_command" {
  type = "list"
}

variable "export_tables_as_csv_to_big_query_task_command" {
  type = "list"
}

variable "update_database_records_in_big_query_task_schedule" {}
variable "export_tables_as_csv_to_big_query_task_schedule" {}
variable "send_job_alerts_daily_email_task_schedule" {}
variable "send_feedback_prompt_email_task_schedule" {}

variable "vacancies_statistics_refresh_cache_task_command" {
  type = "list"
}

variable "vacancies_statistics_refresh_cache_task_schedule" {}
variable "algolia_app_id" {}
variable "algolia_write_api_key" {}
variable "algolia_search_api_key" {}
