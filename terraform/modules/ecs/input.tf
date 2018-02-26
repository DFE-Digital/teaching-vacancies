variable "environment"                 {}
variable "project_name"                {}
variable "region"                      {}
variable "ecs_cluster_name"            {}
variable "ecs_service_name"            {}
variable "ecs_service_task_name"       {}
variable "ecs_service_task_count"      {}
variable "ecs_service_task_port"       {}
variable "aws_alb_target_group_arn"    {}

variable "ecs_service_task_definition_file_path" {}
variable "aws_cloudwatch_log_group_name" {}

variable "http_pass"                   {}
variable "http_user"                   {}
variable "google_maps_api_key"         {}
variable "secret_key_base"             {}
variable "rds_address"                 {}
