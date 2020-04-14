provider "aws" {
  region  = "${var.region}"
  version = "~> 1.36.0"
}

provider "template" {
  version = "~> 1.0.0"
}

/*
Store infrastructure state in a remote store (instead of local machine):
https://www.terraform.io/docs/state/purpose.html
*/
terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    bucket  = "terraform-state-002"
    key     = "tvs/terraform.tfstate" # When using workspaces this changes to ':env/{terraform.workspace}/tvs/terraform.tfstate'
    region  = "eu-west-2"
    encrypt = "true"
  }
}

module "core" {
  source = "./terraform/modules/core"

  environment          = "${terraform.workspace}"
  project_name         = "${var.project_name}"
  vpc_cidr             = "${var.vpc_cidr}"
  availability_zones   = "${var.availability_zones}"
  public_subnets_cidr  = "${var.public_subnets_cidr}"
  private_subnets_cidr = "${var.private_subnets_cidr}"
  availability_zones   = "${var.availability_zones}"
  ssh_ips              = "${var.ssh_ips}"

  region                   = "${var.region}"
  load_balancer_check_path = "${var.load_balancer_check_path}"
  alb_certificate_arn      = "${var.alb_certificate_arn}"
  image_id                 = "${var.image_id}"
  instance_type            = "${var.ecs_instance_type}"

  asg_name         = "${var.asg_name}"
  asg_max_size     = "${var.asg_max_size}"
  asg_min_size     = "${var.asg_min_size}"
  asg_desired_size = "${var.asg_desired_size}"

  domain                            = "${var.domain}"
  redirect_old_teachingjobs_traffic = "${var.redirect_old_teachingjobs_traffic}"

  ecs_cluster_name                  = "${module.ecs.cluster_name}"
  ecs_service_web_name              = "${module.ecs.web_service_name}"
  aws_iam_ecs_instance_profile_name = "${module.ecs.aws_iam_ecs_instance_profile_name}"

  ecs_ssh_public_key = "${var.ecs_ssh_public_key}"
}

module "ecs" {
  source = "./terraform/modules/ecs"

  environment      = "${terraform.workspace}"
  project_name     = "${var.project_name}"
  region           = "${var.region}"
  ecs_cluster_name = "${var.ecs_cluster_name}"

  ecs_service_web_container_definition_file_path = "${var.ecs_service_web_container_definition_file_path}"
  ecs_service_web_name                           = "${var.project_name}_${terraform.workspace}_${var.ecs_service_web_name}"
  ecs_service_web_task_name                      = "${var.project_name}_${terraform.workspace}_${var.ecs_service_web_task_name}"
  ecs_service_web_task_count                     = "${var.ecs_service_web_task_count}"
  ecs_service_web_task_port                      = "${var.ecs_service_web_task_port}"

  ecs_service_worker_container_definition_file_path = "${var.ecs_service_worker_container_definition_file_path}"
  ecs_service_worker_name                           = "${var.project_name}_${terraform.workspace}_${var.ecs_service_worker_name}"
  ecs_service_worker_task_name                      = "${var.project_name}_${terraform.workspace}_${var.ecs_service_worker_task_name}"
  ecs_service_worker_task_port                      = "${var.ecs_service_worker_task_port}"

  worker_command = "${var.worker_command}"

  ecs_service_logspout_container_definition_file_path = "${var.ecs_service_logspout_container_definition_file_path}"
  logspout_command                                    = "${var.logspout_command}"
  ecs_logspout_task_count                             = "${var.asg_min_size}"

  # Rake tasks
  ecs_service_rake_container_definition_file_path          = "${var.ecs_service_rake_container_definition_file_path}"
  performance_platform_rake_container_definition_file_path = "${var.performance_platform_rake_container_definition_file_path}"
  google_api_rake_container_definition_file_path           = "${var.google_api_rake_container_definition_file_path}"

  import_schools_task_command  = "${var.import_schools_task_command}"
  import_schools_task_schedule = "${var.import_schools_task_schedule}"

  update_database_records_in_big_query_task_command = "${var.update_database_records_in_big_query_task_command}"
  update_database_records_in_big_query_task_schedule = "${var.update_database_records_in_big_query_task_schedule}"

  export_tables_as_csv_to_big_query_task_command = "${var.export_tables_as_csv_to_big_query_task_command}"
  export_tables_as_csv_to_big_query_task_schedule = "${var.export_tables_as_csv_to_big_query_task_schedule}"

  send_job_alerts_daily_email_task_command  = "${var.send_job_alerts_daily_email_task_command}"
  send_job_alerts_daily_email_task_schedule = "${var.send_job_alerts_daily_email_task_schedule}"

  send_feedback_prompt_email_task_command = "${var.send_feedback_prompt_email_task_command}"
  send_feedback_prompt_email_task_schedule = "${var.send_feedback_prompt_email_task_schedule}"

  sessions_trim_task_command  = "${var.sessions_trim_task_command}"
  sessions_trim_task_schedule = "${var.sessions_trim_task_schedule}"

  reindex_vacancies_task_command = "${var.reindex_vacancies_task_command}"

  seed_vacancies_from_api_task_command = "${var.seed_vacancies_from_api_task_command}"

  performance_platform_submit_task_command     = "${var.performance_platform_submit_task_command}"
  performance_platform_submit_task_schedule    = "${var.performance_platform_submit_task_schedule}"
  performance_platform_submit_all_task_command = "${var.performance_platform_submit_all_task_command}"

  vacancies_statistics_refresh_cache_task_command  = "${var.vacancies_statistics_refresh_cache_task_command}"
  vacancies_statistics_refresh_cache_task_schedule = "${var.vacancies_statistics_refresh_cache_task_schedule}"

  # Module inputs

  aws_alb_target_group_arn      = "${module.core.alb_target_group_arn}"
  aws_cloudwatch_log_group_name = "${module.logs.aws_cloudwatch_log_group_name}"

  # Application variables

  rails_env                                    = "${var.rails_env}"
  rails_max_threads                            = "${var.rails_max_threads}"
  override_school_urn                          = "${var.override_school_urn}"
  http_pass                                    = "${var.http_pass}"
  http_user                                    = "${var.http_user}"
  dfe_sign_in_issuer                           = "${var.dfe_sign_in_issuer}"
  dfe_sign_in_redirect_url                     = "${var.dfe_sign_in_redirect_url}"
  dfe_sign_in_identifier                       = "${var.dfe_sign_in_identifier}"
  dfe_sign_in_secret                           = "${var.dfe_sign_in_secret}"
  google_maps_api_key                          = "${var.google_maps_api_key}"
  google_tag_manager_container_id              = "${var.google_tag_manager_container_id}"
  rollbar_access_token                         = "${var.rollbar_access_token}"
  rollbar_client_errors_access_token           = "${var.rollbar_client_errors_access_token}"
  pp_transactions_by_channel_token             = "${var.pp_transactions_by_channel_token}"
  secret_key_base                              = "${var.secret_key_base}"
  rds_username                                 = "${var.rds_username}"
  rds_password                                 = "${var.rds_password}"
  rds_address                                  = "${module.rds.rds_address}"
  es_address                                   = "${module.es.es_address}"
  aws_elasticsearch_region                     = "${var.region}"
  aws_elasticsearch_key                        = "${module.es.es_user_access_key_id}"
  aws_elasticsearch_secret                     = "${module.es.es_user_access_key_secret}"
  redis_cache_url                              = "redis://${module.elasticache_redis.redis_cache_endpoint}"
  redis_queue_url                              = "redis://${module.elasticache_redis.redis_queue_endpoint}"
  domain                                       = "${var.domain}"
  google_geocoding_api_key                     = "${var.google_geocoding_api_key}"
  ordnance_survey_api_key                      = "${var.ordnance_survey_api_key}"
  google_api_json_key                          = "${var.google_api_json_key}"
  google_analytics_profile_id                  = "${var.google_analytics_profile_id}"
  subscription_key_generator_secret            = "${var.subscription_key_generator_secret}"
  subscription_key_generator_salt              = "${var.subscription_key_generator_salt}"
  skylight_authentication                      = "${var.skylight_authentication}"
  skylight_env                                 = "${var.skylight_env}"
  skylight_enabled                             = "${var.skylight_enabled}"
  skylight_ignored_endpoints                   = "${var.skylight_ignored_endpoints}"
  notify_key                                   = "${var.notify_key}"
  notify_subscription_confirmation_template    = "${var.notify_subscription_confirmation_template}"
  notify_subscription_daily_template           = "${var.notify_subscription_daily_template}"
  notify_prompt_feedback_for_expired_vacancies = "${var.notify_prompt_feedback_for_expired_vacancies}"
  feature_email_alerts                         = "${var.feature_email_alerts}"
  feature_import_vacancies                     = "${var.feature_import_vacancies}"
  feature_sign_in_alert                        = "${var.feature_sign_in_alert}"
  dfe_sign_in_url                              = "${var.dfe_sign_in_url}"
  dfe_sign_in_password                         = "${var.dfe_sign_in_password}"
  dfe_sign_in_service_access_role_id           = "${var.dfe_sign_in_service_access_role_id}"
  dfe_sign_in_service_id                       = "${var.dfe_sign_in_service_id}"
  google_cloud_platform_project_id             = "${var.google_cloud_platform_project_id}"
  big_query_api_json_key                       = "${var.big_query_api_json_key}"
  big_query_dataset                            = "${var.big_query_dataset}"
  cloud_storage_api_json_key                   = "${var.cloud_storage_api_json_key}"
  cloud_storage_bucket                         = "${var.cloud_storage_bucket}"
  algolia_app_id                               = "${var.aloglia_app_id}"
  algolia_write_api_key                        = "${var.algolia_write_api_key}"
  algolia_search_api_key                       = "${var.algolia_search_api_key}"
}

module "logs" {
  source = "./terraform/modules/logs"

  environment  = "${terraform.workspace}"
  project_name = "${var.project_name}"
}

module "cloudwatch" {
  source = "./terraform/modules/cloudwatch"

  environment            = "${terraform.workspace}"
  project_name           = "${var.project_name}"
  slack_hook_url         = "${var.cloudwatch_slack_hook_url}"
  slack_channel          = "${var.cloudwatch_slack_channel}"
  ops_genie_api_key      = "${var.cloudwatch_ops_genie_api_key}"
  autoscaling_group_name = "${module.core.ecs_autoscaling_group_name}"
  pipeline_name          = "${module.pipeline.pipeline_name}"
  redis_cache_cluster_id = "${module.elasticache_redis.redis_cache_cluster_id}"
}

module "pipeline" {
  source = "./terraform/modules/pipeline"

  environment         = "${terraform.workspace}"
  project_name        = "${var.project_name}"
  aws_account_id      = "${var.aws_account_id}"
  github_token        = "${var.github_token}"
  buildspec_location  = "${var.buildspec_location}"
  git_branch_to_track = "${var.git_branch_to_track}"

  registry_name           = "${module.ecs.registry_name}"
  ecs_cluster_name        = "${module.ecs.cluster_name}"
  ecs_service_web_name    = "${module.ecs.web_service_name}"
  ecs_worker_service_name = "${module.ecs.worker_service_name}"
}

module "rds" {
  source = "./terraform/modules/rds"

  environment        = "${terraform.workspace}"
  project_name       = "${var.project_name}"
  rds_storage_gb     = "${var.rds_storage_gb}"
  rds_instance_type  = "${var.rds_instance_type}"
  rds_engine         = "${var.rds_engine}"
  rds_engine_version = "${var.rds_engine_version[var.rds_engine]}"
  rds_username       = "${var.rds_username}"
  rds_password       = "${var.rds_password}"

  vpc_id                    = "${module.core.vpc_id}"
  default_security_group_id = "${module.core.default_security_group_id}"
}

module "es" {
  source = "./terraform/modules/es"

  environment    = "${terraform.workspace}"
  project_name   = "${var.project_name}"
  instance_count = "${var.es_instance_count}"
  instance_type  = "${var.es_instance_type}"
  es_version     = "${var.es_version}"
  es_domain_name = "${var.project_name}-${terraform.workspace}-default"

  vpc_id                    = "${module.core.vpc_id}"
  default_security_group_id = "${module.core.default_security_group_id}"
}

module "cloudfront" {
  source = "./terraform/modules/cloudfront"

  environment                   = "${terraform.workspace}"
  project_name                  = "${var.project_name}"
  cloudfront_origin_domain_name = "${module.core.alb_dns_name}"
  cloudfront_aliases            = "${var.cloudfront_aliases}"
  cloudfront_certificate_arn    = "${var.cloudfront_certificate_arn}"
  offline_bucket_domain_name    = "${var.offline_bucket_domain_name}"
  offline_bucket_origin_path    = "${var.offline_bucket_origin_path}"
}

module "elasticache_redis" {
  source = "./terraform/modules/elasticache-redis"

  cluster_id                = "${var.project_name}-${terraform.workspace}"
  engine_version            = "${var.elasticache_redis_engine_version}"
  redis_cache_instance_type = "${var.elasticache_redis_cache_instance_type}"
  redis_queue_instance_type = "${var.elasticache_redis_queue_instance_type}"
  parameter_group_name      = "${var.elasticache_redis_parameter_group_name}"
  maintenance_window        = "${var.elasticache_redis_maintenance_window}"
  vpc_id                    = "${module.core.vpc_id}"
  private_subnet_ids        = "${join(",", module.core.private_subnet_ids)}"

  tag_name          = "${var.project_name}-${terraform.workspace}"
  tag_environment   = "${terraform.workspace}"
  tag_team          = "dfe"
  tag_contact-email = ""
  tag_customer      = ""
  tag_application   = "tvs"

  default_security_group_id = "${module.core.default_security_group_id}"
}
