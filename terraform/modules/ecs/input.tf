variable "environment" {}
variable "project_name" {}
variable "region" {}
variable "ecs_cluster_name" {}
variable "ecs_service_name" {}
variable "ecs_service_task_name" {}
variable "ecs_service_task_count" {}
variable "ecs_service_task_port" {}
variable "aws_alb_target_group_arn" {}

variable "ecs_service_task_definition_file_path" {}
variable "ecs_import_schools_task_definition_file_path" {}
variable "ecs_vacancies_scrape_task_definition_file_path" {}
variable "aws_cloudwatch_log_group_name" {}

variable "rails_env" {}
variable "http_pass" {}
variable "http_user" {}
variable "google_maps_api_key" {}
variable "google_analytics" {}
variable "rollbar_access_token" {}
variable "secret_key_base" {}
variable "rds_username" {}
variable "rds_password" {}
variable "rds_address" {}
variable "es_address" {}
variable "aws_elasticsearch_region" {}
variable "aws_elasticsearch_key" {}
variable "aws_elasticsearch_secret" {}

variable "import_schools_entrypoint" {
  type = "list"
}

variable "vacancies_scrape_entrypoint" {
  type = "list"
}

variable "vacancies_scrape_schedule_expression" {}
variable "web_service_entrypoint"                 { type = "list"}
