provider "aws" {
  region = "${var.region}"
}

/*
Store infrastructure state in a remote store (instead of local machine):
https://www.terraform.io/docs/state/purpose.html
*/
terraform {
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
  ecs_key_pair_name        = "${var.ecs_key_pair_name}"

  asg_name         = "${var.asg_name}"
  asg_max_size     = "${var.asg_max_size}"
  asg_min_size     = "${var.asg_min_size}"
  asg_desired_size = "${var.asg_desired_size}"

  ecs_cluster_name                  = "${module.ecs.cluster_name}"
  ecs_service_name                  = "${module.ecs.service_name}"
  aws_iam_ecs_instance_profile_name = "${module.ecs.aws_iam_ecs_instance_profile_name}"
}

module "ecs" {
  source = "./terraform/modules/ecs"

  environment                                    = "${terraform.workspace}"
  project_name                                   = "${var.project_name}"
  region                                         = "${var.region}"
  ecs_cluster_name                               = "${var.ecs_cluster_name}"
  ecs_service_name                               = "${var.project_name}_${terraform.workspace}_${var.ecs_service_name}"
  ecs_service_task_name                          = "${var.project_name}_${terraform.workspace}_${var.ecs_service_task_name}"
  ecs_service_task_count                         = "${var.ecs_service_task_count}"
  ecs_service_task_port                          = "${var.ecs_service_task_port}"
  ecs_service_task_definition_file_path          = "${var.ecs_service_task_definition_file_path}"
  ecs_import_schools_task_definition_file_path   = "${var.ecs_import_schools_task_definition_file_path}"
  ecs_vacancies_scrape_task_definition_file_path = "${var.ecs_vacancies_scrape_task_definition_file_path}"
  import_schools_entrypoint                      = ["/bin/bash","-c","${module.container_bootstrap.entrypoint} ${var.import_schools_entrypoint}"]
  vacancies_scrape_entrypoint                    = ["/bin/bash","-c","${module.container_bootstrap.entrypoint} ${var.vacancies_scrape_entrypoint}"]
  vacancies_scrape_schedule_expression           = "${var.vacancies_scrape_schedule_expression}"
  web_service_entrypoint                         = ["/bin/bash","-c","${module.container_bootstrap.entrypoint} ${var.web_service_entrypoint}"]

  aws_alb_target_group_arn      = "${module.core.alb_target_group_arn}"
  aws_cloudwatch_log_group_name = "${module.logs.aws_cloudwatch_log_group_name}"

  # Application variables
  rails_env                = "${var.rails_env}"
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
}

module "pipeline" {
  source = "./terraform/modules/pipeline"

  environment         = "${terraform.workspace}"
  project_name        = "${var.project_name}"
  aws_account_id      = "${var.aws_account_id}"
  github_token        = "${var.github_token}"
  buildspec_location  = "${var.buildspec_location}"
  git_branch_to_track = "${var.git_branch_to_track}"

  registry_name    = "${module.ecs.registry_name}"
  ecs_cluster_name = "${module.ecs.cluster_name}"
  ecs_service_name = "${module.ecs.service_name}"
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
}

module "container_bootstrap" {
  source               = "./terraform/modules/container_bootstrap"

  environment          = "${terraform.workspace}"
  project_name         = "${var.project_name}"
  region               = "${var.region}"
  parameter_store_path = "/${var.project_name}_${terraform.workspace}/envars"
  dotenv_user          = "${var.container_bootstrap_dotenv_user}"
  ecs_task_role_id     = "${module.ecs.execution_role_id}"
}

module "parameter_store" {
  source                   = "./terraform/modules/parameter_store"
  namespace                = "/${var.project_name}_${terraform.workspace}/envars"
  kms_key_alias            = "${module.container_bootstrap.parameter_store_kms_key_alias}"
  string_parameters        = [
                               "AWS_ELASTICSEARCH_REGION=${var.region}",
                               "ELASTICSEARCH_AWS_SIGNING=true",
                               "GOOGLE_ANALYTICS=${var.google_analytics}",
                               "HTTP_USER=${var.http_user}",
                               "RAILS_LOG_TO_STDOUT=true",
                               "RAILS_SERVE_STATIC_FILES=true"
                             ]
  secure_string_parameters = [
                               "GOOGLE_MAPS_API_KEY=${var.google_maps_api_key}",
                               "HTTP_PASS=${var.http_pass}",
                               "ROLLBAR_ACCESS_TOKEN=${var.rollbar_access_token}",
                               "SECRET_KEY_BASE=${var.secret_key_base}",
                               "ELASTICSEARCH_URL=https://${module.es.es_address}:443",
                               "AWS_ELASTICSEARCH_KEY=${module.es.es_user_access_key_id}",
                               "AWS_ELASTICSEARCH_SECRET=${module.es.es_user_access_key_secret}",
                               "DATABASE_URL=postgres://${var.rds_username}:${var.rds_password}@${module.rds.rds_address}:5432/${var.project_name}_${terraform.workspace}?template=template0&pool=5&encoding=unicode"
                             ]
}
