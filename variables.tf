variable "aws_account_id" {
  description = "AWS account ID"
}

variable "github_token" {
  description = "GitHub auth token that can read from the GitHub repository"
}

variable "project_name" {
  description = "This name will be used to identify all AWS resources. The workspace name will be suffixed. Alphanumeric characters only due to RDS."
}

variable "buildspec_location" {
  description = "AWS Codebuild will look for this file to tell it how to build this project"
  default     = "./buildspec.yml"
}

variable "git_branch_to_track" {
  description = "Git branch to listen for code changes on and auto deploy"
  default     = "master"
}

# Network
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  default = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "ssh_ips" {
  description = "IPs with a degree of trust "
  type        = "list"
}

# EC2

variable "region" {
  default = "eu-west-2"
}

# EC2
variable "availability_zones" {
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "image_id" {
  default = "ami-67cbd003" # Make sure this AWS AMI is valid for the chosen region.
}

variable "ecs_instance_type" {
  description = "The size of the EC2 instances to use"
  default     = "t2.micro"
}

variable "asg_name" {
  default = "scheduling-default-asg"
}

variable "asg_max_size" {
  description = "The maximum EC2 count for the default autoscaling group policy"
  default     = 1
}

variable "asg_min_size" {
  description = "The minimum EC2 count for the default autoscaling group policy"
  default     = 1
}

variable "asg_desired_size" {
  description = "The prefferd EC2 count for the default autoscaling group policy"
  default     = 1
}

variable "alb_certificate_arn" {
  description = "The certificate ARN to attach to the ALB's HTTPS listener"
}

variable "domain" {}
variable "redirect_old_teachingjobs_traffic" {}

# ECS
variable "ecs_cluster_name" {}

variable "ecs_ssh_public_key" {
  description = "This key will be placed onto the machines by Terraform to allow SSH"
}

variable "ecs_service_web_name" {
  default = "default-web"
}

variable "ecs_service_web_task_name" {
  default = "web"
}

variable "ecs_service_web_task_count" {
  description = "The number of containers to run for this service"
  default     = 1
}

variable "ecs_service_web_task_port" {
  description = "The port this application is listening on (ALB will map these with ephemeral port numbers)"
  default     = 3000
}

variable "ecs_service_worker_name" {
  default = "worker"
}

variable "ecs_service_worker_task_name" {
  default = "worker"
}

variable "ecs_service_worker_task_port" {
  description = "The port the worker is listening on (ALB will map these with ephemeral port numbers)"
  default     = 3000
}

# ECS Tasks
variable "ecs_service_web_container_definition_file_path" {
  description = "Container definition for the web task"
  default     = "./terraform/container-definitions/web_container_definition.json"
}

# Rake task container definitions
variable "ecs_service_rake_container_definition_file_path" {
  description = "Container definition for rake tasks"
  default     = "./terraform/container-definitions/rake_container_definition.json"
}

variable "performance_platform_rake_container_definition_file_path" {
  description = "Container definition for rake tasks"
  default     = "./terraform/container-definitions/performance_platform_rake_container_definition.json"
}

variable "google_api_rake_container_definition_file_path" {
  description = "Container definition for rake tasks using Google API"
  default     = "./terraform/container-definitions/google_api_rake_container_definition.json"
}

variable "ecs_service_logspout_container_definition_file_path" {
  description = "Logspout container definition"
  default     = "./terraform/container-definitions/logspout_container_definition.json"
}

variable "ecs_service_worker_container_definition_file_path" {
  description = "Worker container definition"
  default     = "./terraform/container-definitions/worker_container_definition.json"
}

variable "send_job_alerts_daily_email_task_command" {
  description = "The Entrypoint for the send_job_alerts_daily_email task"
  default     = ["rake", "verbose", "daily_emails:send"]
}

variable "send_job_alerts_daily_email_task_schedule" {
  description = "send_job_alerts_daily_email schedule expression - https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  default     = "cron(0 08 * * ? *)"
}

variable "send_feedback_prompt_email_task_command" {
  description = "The Entrypoint for the send_feedback_prompt_email task"
  default     = ["rake", "verbose", "feedback_prompt_email:send"]
}

variable "send_feedback_prompt_email_task_schedule" {
  description = "send_feedback_prompt_email schedule expression - https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  default     = "cron(0 09 * * ? *)"
}

variable "import_schools_task_command" {
  description = "The Entrypoint for the import_schools task"
  default     = ["rake", "verbose", "data:schools:import"]
}

variable "import_schools_task_schedule" {
  description = "import_schools schedule expression - https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  default     = "cron(0 07 * * ? *)"
}

variable "update_database_records_in_big_query_task_command" {
  description = "The Entrypoint for the update_database_records_in_big_query task"
  default     = ["rake", "verbose", "database_records:in_big_query:update"]
}

variable "update_database_records_in_big_query_task_schedule" {
  description = "update_database_records_in_big_query schedule expression - https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  default     = "cron(0 03 * * ? *)"
}

variable "export_tables_as_csv_to_big_query_task_command" {
  description = "The Entrypoint for the export_tables_as_csv_to_big_query task"
  default     = ["rake", "verbose", "tables_as_csv:to_big_query:export"]
}

variable "export_tables_as_csv_to_big_query_task_schedule" {
  description = "export_tables_as_csv_to_big_query schedule expression - https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  default     = "cron(0 01 * * ? *)"
}

variable "sessions_trim_task_command" {
  description = "The Entrypoint for trimming old sessions"
  default     = ["rake", "verbose", "db:sessions:trim"]
}

variable "sessions_trim_task_schedule" {
  description = "sessions_trim schedule expression - https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  default     = "rate(1 day)"
}

variable "reindex_vacancies_task_command" {
  description = "The Entrypoint for the reindex_vacancies task"
  default     = ["rake", "verbose", "elasticsearch:vacancies:index"]
}

variable "seed_vacancies_from_api_task_command" {
  description = "The Entrypoint for the data:seed_from_api:vacancies task"
  default     = ["rake", "verbose", "data:seed_from_api:vacancies"]
}

variable "performance_platform_submit_task_command" {
  description = "The Entrypoint for the performance_platform_submit task"
  default     = ["rake", "verbose", "performance_platform:submit"]
}

variable "performance_platform_submit_task_schedule" {
  description = "performance_platform_submit schedule expression - https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  default     = "rate(24 hours)"
}

variable "performance_platform_submit_all_task_command" {
  description = "The Entrypoint for the performance_platform_submit_all task"
  default     = ["rake", "verbose", "performance_platform:submit_data_up_to_today"]
}

variable "vacancies_statistics_refresh_cache_task_command" {
  description = "The Entrypoint for the vacancies_statistics_refresh_cache task"
  default     = ["rake", "verbose", "vacancies:statistics:refresh_cache"]
}

variable "vacancies_statistics_refresh_cache_task_schedule" {
  description = "vacancies_statistics_refresh_cache schedule expression - https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  default     = "cron(0 02 * * ? *)"
}

# RDS
variable "rds_engine" {
  default     = "postgres"
  description = "Engine type, example values mysql, postgres"
}

variable "rds_engine_version" {
  description = "Engine version"

  default = {
    mysql    = "5.6.22"
    postgres = "9.6"
  }
}

variable "rds_storage_gb" {}
variable "rds_username" {}
variable "rds_password" {}

variable "rds_instance_type" {
  default = "db.t2.micro"
}

# Elastic search
variable "es_version" {
  description = "Amazon Elasticsearch Service currently supports Elasticsearch versions 6.0, 5.5, 5.3, 5.1, 2.3, and 1.5."
  default     = "6.0"
}

variable "es_instance_count" {
  default = 2
}

variable "es_instance_type" {
  default = "t2.small.elasticsearch"
}

# Elasticache

variable "elasticache_redis_engine_version" {
  default = "4.0.10"
}

variable "elasticache_redis_cache_instance_type" {
  default = "cache.t2.small"
}

variable "elasticache_redis_queue_instance_type" {
  default = "cache.t2.small"
}

variable "elasticache_redis_parameter_group_name" {
  default = "default.redis4.0"
}

variable "elasticache_redis_maintenance_window" {
  default = "sun:01:00-sun:02:00"
}

# CloudFront
variable "cloudfront_certificate_arn" {
  description = "Create and verify a certificate through AWS Certificate Manager to acquire this"
}

variable "cloudfront_aliases" {
  description = "Match this value to the alias associated with the cloudfront_certificate_arn, eg. tvs.staging.dxw.net"
  type        = "list"
}

variable "offline_bucket_domain_name" {}
variable "offline_bucket_origin_path" {}

# Cloudwatch
variable "cloudwatch_slack_hook_url" {
  description = "The slack hook that cloudwatch alarms are sent to"
}

variable "cloudwatch_slack_channel" {
  description = "The slack channel that cloudwatch alarms are sent to"
}

variable "cloudwatch_ops_genie_api_key" {
  description = "The ops genie api key for sending alerts to ops genie"
}

variable "load_balancer_check_path" {
  default = "/"
}

variable "logspout_command" {
  type = "list"
}

variable "worker_command" {
  type = "list"
}

# Application
variable "rails_env" {}

variable "rails_max_threads" {
  default = "5"
}

variable "override_school_urn" {}
variable "http_user" {}
variable "http_pass" {}
variable "dfe_sign_in_issuer" {}
variable "dfe_sign_in_redirect_url" {}
variable "dfe_sign_in_identifier" {}
variable "dfe_sign_in_secret" {}
variable "google_maps_api_key" {}
variable "google_tag_manager_container_id" {}
variable "secret_key_base" {}

variable "google_geocoding_api_key" {}

variable "ordnance_survey_api_key" {}

variable "rollbar_access_token" {}
variable "rollbar_client_errors_access_token" {}
variable "pp_transactions_by_channel_token" {}

variable "google_api_json_key" {
  type = "map"
}

variable "google_analytics_profile_id" {}
variable "skylight_authentication" {}
variable "skylight_env" {}
variable "skylight_enabled" {}

variable "skylight_ignored_endpoints" {
  default = "ApplicationController#check"
}

variable "notify_key" {}
variable "feature_email_alerts" {}

variable "feature_import_vacancies" {
  default = "false"
}

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
  type = "string"
}

variable "cloud_storage_api_json_key" {
  type = "map"
}

variable "cloud_storage_bucket" {
  description = "Cloud Storage Bucket name"
  type        = "string"
}

variable "feature_sign_in_alert" {
  default = "false"
}

variable "algolia_app_id" {}
variable "algolia_write_api_key" {}
variable "algolia_search_api_key" {}
