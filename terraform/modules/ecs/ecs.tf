/*====
ECR repository to store our Docker images
======*/
resource "aws_ecr_repository" "default" {
  name = "${var.project_name}-${var.environment}"
}

resource "aws_ecr_lifecycle_policy" "autoexpire" {
  repository = "${aws_ecr_repository.default.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 10,
            "description": "Expire images older than 60 days",
            "selection": {
                "tagStatus": "any",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 60
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

/*====
ECS cluster
======*/
resource "aws_ecs_cluster" "cluster" {
  name = "${var.ecs_cluster_name}-${var.environment}"
}

/*====
ECS Service
======*/
resource "aws_ecs_service" "web" {
  name            = "${var.ecs_service_web_name}"
  iam_role        = "${aws_iam_role.ecs_role.arn}"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.web.family}:${max("${aws_ecs_task_definition.web.revision}", "${data.aws_ecs_task_definition.web.revision}")}"
  desired_count   = "${var.ecs_service_web_task_count}"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 100

  health_check_grace_period_seconds = 30

  load_balancer {
    target_group_arn = "${var.aws_alb_target_group_arn}"
    container_name   = "${var.ecs_service_web_task_name}"
    container_port   = "${var.ecs_service_web_task_port}"
  }

  depends_on = ["aws_iam_role.ecs_role"]

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

resource "aws_ecs_service" "logspout" {
  name            = "logspout-${var.environment}"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.logspout.family}:${max("${aws_ecs_task_definition.logspout.revision}", "${data.aws_ecs_task_definition.logspout.revision}")}"
  desired_count   = "${var.ecs_logspout_task_count}"

  deployment_minimum_healthy_percent = 50

  scheduling_strategy = "DAEMON"

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

resource "aws_ecs_service" "worker" {
  name            = "${var.ecs_service_worker_name}"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.worker.family}:${max("${aws_ecs_task_definition.worker.revision}", "${data.aws_ecs_task_definition.worker.revision}")}"
  desired_count   = "${var.ecs_service_web_task_count}"

  deployment_minimum_healthy_percent = 50

  scheduling_strategy = "DAEMON"

  depends_on = ["aws_iam_role.ecs_role"]
}

/*====
ECS task definitions
======*/

/* scheduled task role */
resource "aws_iam_role" "scheduled_task_role" {
  name = "${var.project_name}-${var.environment}-scheduled-task-role"

  assume_role_policy = "${file("./terraform/policies/ecs-scheduled-task-role.json")}"
}

/* scheduled task policy */
data "template_file" "scheduled_task_policy" {
  template = "${file("./terraform/policies/ecs-scheduled-task-policy.json")}"

  vars {
    task_execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  }
}

resource "aws_iam_role_policy" "scheduled_task_policy" {
  name   = "${var.project_name}-${var.environment}-scheduled-task-policy"
  role   = "${aws_iam_role.scheduled_task_role.id}"
  policy = "${data.template_file.scheduled_task_policy.rendered}"
}

/* the task definition for the web service */
data "template_file" "web_container_definition" {
  template = "${file(var.ecs_service_web_container_definition_file_path)}"

  vars {
    image                                        = "${aws_ecr_repository.default.repository_url}"
    override_school_urn                          = "${var.override_school_urn}"
    http_user                                    = "${var.http_user}"
    http_pass                                    = "${var.http_pass}"
    dfe_sign_in_issuer                           = "${var.dfe_sign_in_issuer}"
    dfe_sign_in_redirect_url                     = "${var.dfe_sign_in_redirect_url}"
    dfe_sign_in_identifier                       = "${var.dfe_sign_in_identifier}"
    dfe_sign_in_secret                           = "${var.dfe_sign_in_secret}"
    google_maps_api_key                          = "${var.google_maps_api_key}"
    google_tag_manager_container_id              = "${var.google_tag_manager_container_id}"
    rollbar_access_token                         = "${var.rollbar_access_token}"
    rollbar_client_errors_access_token           = "${var.rollbar_client_errors_access_token}"
    secret_key_base                              = "${var.secret_key_base}"
    project_name                                 = "${var.project_name}"
    task_name                                    = "${var.ecs_service_web_task_name}"
    task_port                                    = "${var.ecs_service_web_task_port}"
    environment                                  = "${var.environment}"
    rails_env                                    = "${var.rails_env}"
    rails_max_threads                            = "${var.rails_max_threads}"
    region                                       = "${var.region}"
    log_group                                    = "${var.aws_cloudwatch_log_group_name}"
    database_user                                = "${var.rds_username}"
    database_password                            = "${var.rds_password}"
    database_url                                 = "${var.rds_address}"
    elastic_search_url                           = "${var.es_address}"
    aws_elasticsearch_region                     = "${var.aws_elasticsearch_region}"
    aws_elasticsearch_key                        = "${var.aws_elasticsearch_key}"
    aws_elasticsearch_secret                     = "${var.aws_elasticsearch_secret}"
    redis_cache_url                              = "${var.redis_cache_url}"
    redis_queue_url                              = "${var.redis_queue_url}"
    google_geocoding_api_key                     = "${var.google_geocoding_api_key}"
    ordnance_survey_api_key                      = "${var.ordnance_survey_api_key}"
    pp_transactions_by_channel_token             = "${var.pp_transactions_by_channel_token}"
    domain                                       = "${var.domain}"
    google_api_json_key                          = "${replace(jsonencode(var.google_api_json_key), "/([\"\\\\])/", "\\$1")}"
    google_analytics_profile_id                  = "${var.google_analytics_profile_id}"
    skylight_authentication                      = "${var.skylight_authentication}"
    skylight_env                                 = "${var.skylight_env}"
    skylight_enabled                             = "${var.skylight_enabled}"
    skylight_ignored_endpoints                   = "${var.skylight_ignored_endpoints}"
    notify_key                                   = "${var.notify_key}"
    notify_subscription_confirmation_template    = "${var.notify_subscription_confirmation_template}"
    notify_subscription_daily_template           = "${var.notify_subscription_daily_template}"
    notify_prompt_feedback_for_expired_vacancies = "${var.notify_prompt_feedback_for_expired_vacancies}"
    subscription_key_generator_salt              = "${var.subscription_key_generator_salt}"
    subscription_key_generator_secret            = "${var.subscription_key_generator_secret}"
    feature_email_alerts                         = "${var.feature_email_alerts}"
    feature_import_vacancies                     = "${var.feature_import_vacancies}"
    feature_sign_in_alert                        = "${var.feature_sign_in_alert}"
    feature_read_only                            = "${var.feature_read_only}"
    dfe_sign_in_url                              = "${var.dfe_sign_in_url}"
    dfe_sign_in_password                         = "${var.dfe_sign_in_password}"
    dfe_sign_in_service_access_role_id           = "${var.dfe_sign_in_service_access_role_id}"
    dfe_sign_in_service_id                       = "${var.dfe_sign_in_service_id}"
    google_cloud_platform_project_id             = "${var.google_cloud_platform_project_id}"
    big_query_api_json_key                       = "${replace(jsonencode(var.big_query_api_json_key), "/([\"\\\\])/", "\\$1")}"
    big_query_dataset                            = "${var.big_query_dataset}"
    cloud_storage_api_json_key                   = "${replace(jsonencode(var.cloud_storage_api_json_key), "/([\"\\\\])/", "\\$1")}"
    cloud_storage_bucket                         = "${var.cloud_storage_bucket}"
    algolia_app_id                               = "${var.algolia_app_id}"
    algolia_write_api_key                        = "${var.algolia_write_api_key}"
    algolia_search_api_key                       = "${var.algolia_search_api_key}"
  }
}

module "rake_container_definition" {
  source = "../container-definitions/rake-container-definition"

  template_file_path = "${var.ecs_service_rake_container_definition_file_path}"

  image                    = "${aws_ecr_repository.default.repository_url}"
  secret_key_base          = "${var.secret_key_base}"
  project_name             = "${var.project_name}"
  environment              = "${var.environment}"
  rails_env                = "${var.rails_env}"
  rails_max_threads        = "${var.rails_max_threads}"
  redis_cache_url          = "${var.redis_cache_url}"
  redis_queue_url          = "${var.redis_queue_url}"
  region                   = "${var.region}"
  log_group                = "${var.aws_cloudwatch_log_group_name}"
  database_user            = "${var.rds_username}"
  database_password        = "${var.rds_password}"
  database_url             = "${var.rds_address}"
  elastic_search_url       = "${var.es_address}"
  aws_elasticsearch_region = "${var.aws_elasticsearch_region}"
  aws_elasticsearch_key    = "${var.aws_elasticsearch_key}"
  aws_elasticsearch_secret = "${var.aws_elasticsearch_secret}"
  feature_import_vacancies = "${var.feature_import_vacancies}"

  rollbar_access_token = "${var.rollbar_access_token}"
}

module "performance_platform_rake_container_definition" {
  source = "../container-definitions/performance-platform-rake-container-definition"

  template_file_path = "${var.performance_platform_rake_container_definition_file_path}"

  image                    = "${aws_ecr_repository.default.repository_url}"
  secret_key_base          = "${var.secret_key_base}"
  project_name             = "${var.project_name}"
  environment              = "${var.environment}"
  rails_env                = "${var.rails_env}"
  rails_max_threads        = "${var.rails_max_threads}"
  redis_cache_url          = "${var.redis_cache_url}"
  redis_queue_url          = "${var.redis_queue_url}"
  region                   = "${var.region}"
  log_group                = "${var.aws_cloudwatch_log_group_name}"
  database_user            = "${var.rds_username}"
  database_password        = "${var.rds_password}"
  database_url             = "${var.rds_address}"
  elastic_search_url       = "${var.es_address}"
  aws_elasticsearch_region = "${var.aws_elasticsearch_region}"
  aws_elasticsearch_key    = "${var.aws_elasticsearch_key}"
  aws_elasticsearch_secret = "${var.aws_elasticsearch_secret}"
  feature_import_vacancies = "${var.feature_import_vacancies}"

  pp_transactions_by_channel_token = "${var.pp_transactions_by_channel_token}"
}

module "google_api_rake_container_definition" {
  source = "../container-definitions/google-api-rake-container-definition"

  template_file_path = "${var.google_api_rake_container_definition_file_path}"

  image                    = "${aws_ecr_repository.default.repository_url}"
  secret_key_base          = "${var.secret_key_base}"
  project_name             = "${var.project_name}"
  environment              = "${var.environment}"
  rails_env                = "${var.rails_env}"
  rails_max_threads        = "${var.rails_max_threads}"
  redis_cache_url          = "${var.redis_cache_url}"
  redis_queue_url          = "${var.redis_queue_url}"
  region                   = "${var.region}"
  log_group                = "${var.aws_cloudwatch_log_group_name}"
  database_user            = "${var.rds_username}"
  database_password        = "${var.rds_password}"
  database_url             = "${var.rds_address}"
  elastic_search_url       = "${var.es_address}"
  aws_elasticsearch_region = "${var.aws_elasticsearch_region}"
  aws_elasticsearch_key    = "${var.aws_elasticsearch_key}"
  aws_elasticsearch_secret = "${var.aws_elasticsearch_secret}"
  feature_import_vacancies = "${var.feature_import_vacancies}"

  google_api_json_key         = "${replace(jsonencode(var.google_api_json_key), "/([\"\\\\])/", "\\$1")}"
  google_analytics_profile_id = "${var.google_analytics_profile_id}"
}

data "template_file" "logspout_container_definition" {
  template = "${file(var.ecs_service_logspout_container_definition_file_path)}"

  vars {
    task_name        = "logspout-${var.environment}"
    logspout_command = "${jsonencode(var.logspout_command)}"
  }
}

/* task definition for the worker service */
data "template_file" "worker_container_definition" {
  template = "${file(var.ecs_service_worker_container_definition_file_path)}"

  vars {
    image           = "${aws_ecr_repository.default.repository_url}"
    secret_key_base = "${var.secret_key_base}"
    project_name    = "${var.project_name}"
    task_name       = "${var.ecs_service_web_task_name}"
    task_port       = "${var.ecs_service_worker_task_port}"

    environment              = "${var.environment}"
    rails_env                = "${var.rails_env}"
    rails_max_threads        = "${var.rails_max_threads}"
    region                   = "${var.region}"
    log_group                = "${var.aws_cloudwatch_log_group_name}"
    database_user            = "${var.rds_username}"
    database_password        = "${var.rds_password}"
    database_url             = "${var.rds_address}"
    elastic_search_url       = "${var.es_address}"
    aws_elasticsearch_region = "${var.aws_elasticsearch_region}"
    aws_elasticsearch_key    = "${var.aws_elasticsearch_key}"
    aws_elasticsearch_secret = "${var.aws_elasticsearch_secret}"

    rollbar_access_token = "${var.rollbar_access_token}"
    redis_cache_url      = "${var.redis_cache_url}"
    redis_queue_url      = "${var.redis_queue_url}"

    pp_transactions_by_channel_token             = "${var.pp_transactions_by_channel_token}"
    google_api_json_key                          = "${replace(jsonencode(var.google_api_json_key), "/([\"\\\\])/", "\\$1")}"
    google_analytics_profile_id                  = "${var.google_analytics_profile_id}"
    domain                                       = "${var.domain}"
    dfe_sign_in_url                              = "${var.dfe_sign_in_url}"
    dfe_sign_in_password                         = "${var.dfe_sign_in_password}"
    google_cloud_platform_project_id             = "${var.google_cloud_platform_project_id}"
    big_query_api_json_key                       = "${replace(jsonencode(var.big_query_api_json_key), "/([\"\\\\])/", "\\$1")}"
    big_query_dataset                            = "${var.big_query_dataset}"
    cloud_storage_api_json_key                   = "${replace(jsonencode(var.cloud_storage_api_json_key), "/([\"\\\\])/", "\\$1")}"
    cloud_storage_bucket                         = "${var.cloud_storage_bucket}"
    notify_key                                   = "${var.notify_key}"
    notify_subscription_confirmation_template    = "${var.notify_subscription_confirmation_template}"
    notify_subscription_daily_template           = "${var.notify_subscription_daily_template}"
    notify_prompt_feedback_for_expired_vacancies = "${var.notify_prompt_feedback_for_expired_vacancies}"
    subscription_key_generator_salt              = "${var.subscription_key_generator_salt}"
    subscription_key_generator_secret            = "${var.subscription_key_generator_secret}"
    feature_email_alerts                         = "${var.feature_email_alerts}"
    ordnance_survey_api_key                      = "${var.ordnance_survey_api_key}"
    worker_command                               = "${jsonencode(var.worker_command)}"
  }
}

resource "aws_ecs_task_definition" "web" {
  family                   = "${var.ecs_service_web_task_name}"
  container_definitions    = "${data.template_file.web_container_definition.rendered}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

data "aws_ecs_task_definition" "web" {
  task_definition = "${aws_ecs_task_definition.web.family}"
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.ecs_service_worker_name}"
  container_definitions    = "${data.template_file.worker_container_definition.rendered}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "1024"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

data "aws_ecs_task_definition" "worker" {
  task_definition = "${aws_ecs_task_definition.worker.family}"
}

resource "aws_ecs_task_definition" "logspout" {
  family                = "ecs-logspout-${var.environment}"
  container_definitions = "${data.template_file.logspout_container_definition.rendered}"
  memory                = "128"

  volume {
    name      = "dockersock"
    host_path = "/var/run/docker.sock"
  }
}

data "aws_ecs_task_definition" "logspout" {
  task_definition = "${aws_ecs_task_definition.logspout.family}"
}

/*====
IAM service role
======*/

data "aws_iam_policy_document" "ecs_service_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_role" {
  name               = "${var.project_name}_${var.environment}_ecs_role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_service_role.json}"
}

/* ecs service scheduler role */
resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "${var.project_name}_${var.environment}_ecs_service_role_policy"
  policy = "${file("./terraform/policies/ecs-service-role-policy.json")}"
  role   = "${aws_iam_role.ecs_role.id}"
}

/* role that the Amazon ECS container agent and the Docker daemon can assume */
resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.project_name}_${var.environment}_ecs_task_execution_role"
  assume_role_policy = "${file("./terraform/policies/ecs-task-execution-role.json")}"
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "${var.project_name}_${var.environment}_ecs_execution_role_policy"
  policy = "${file("./terraform/policies/ecs-execution-role-policy.json")}"
  role   = "${aws_iam_role.ecs_execution_role.id}"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "${var.project_name}-${var.environment}-ecs-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs-instance-role.name}"
}

/*====
ECS SERVICE ROLE
======*/

resource "aws_iam_role" "ecs-instance-role" {
  name               = "${var.project_name}-${var.environment}-ecs-instance-role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-instance-policy.json}"
}

data "aws_iam_policy_document" "ecs-instance-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = "${aws_iam_role.ecs-instance-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

/*====
ECS ONE-OFF TASKS
======*/

module "reindex_vacancies_task" {
  source = "../ecs-task"

  task_name    = "${var.ecs_service_web_task_name}_reindex_vacancies"
  task_command = "${var.reindex_vacancies_task_command}"

  container_definition_template = "${module.rake_container_definition.template}"

  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn      = "${aws_iam_role.ecs_execution_role.arn}"
}

module "seed_vacancies_from_api_task" {
  source = "../ecs-task"

  task_name    = "${var.ecs_service_web_task_name}_seed_vacancies_from_api"
  task_command = "${var.seed_vacancies_from_api_task_command}"

  container_definition_template = "${module.rake_container_definition.template}"

  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn      = "${aws_iam_role.ecs_execution_role.arn}"
}

module "performance_platform_submit_all_task" {
  source = "../ecs-task"

  task_name    = "${var.ecs_service_web_task_name}_performance_platform_submit_all"
  task_command = "${var.performance_platform_submit_all_task_command}"

  container_definition_template = "${module.performance_platform_rake_container_definition.template}"

  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn      = "${aws_iam_role.ecs_execution_role.arn}"
}

/*====
ECS SCHEDULED TASKS
======*/

module "sessions_trim_task" {
  source = "../scheduled-ecs-task"

  task_name        = "${var.ecs_service_web_task_name}_sessions_trim"
  task_description = "Trim sessions"
  task_command     = "${var.sessions_trim_task_command}"
  task_schedule    = "${var.sessions_trim_task_schedule}"

  container_definition_template = "${module.rake_container_definition.template}"

  ecs_cluster_arn = "${aws_ecs_cluster.cluster.arn}"

  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn      = "${aws_iam_role.ecs_execution_role.arn}"
  event_role_arn     = "${aws_iam_role.scheduled_task_role.arn}"
}

module "send_job_alerts_daily_email_task" {
  source = "../scheduled-ecs-task"

  task_name        = "${var.ecs_service_web_task_name}_send_job_alerts_daily_email"
  task_description = "Send daily job alert emails"
  task_command     = "${var.send_job_alerts_daily_email_task_command}"
  task_schedule    = "${var.send_job_alerts_daily_email_task_schedule}"

  container_definition_template = "${module.rake_container_definition.template}"

  ecs_cluster_arn = "${aws_ecs_cluster.cluster.arn}"

  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn      = "${aws_iam_role.ecs_execution_role.arn}"
  event_role_arn     = "${aws_iam_role.scheduled_task_role.arn}"
}

module "send_feedback_prompt_email_task" {
  source = "../scheduled-ecs-task"

  task_name        = "${var.ecs_service_web_task_name}_send_feedback_prompt_email"
  task_description = "Send daily feedback prompt emails for expired vacancies"
  task_command     = "${var.send_feedback_prompt_email_task_command}"
  task_schedule    = "${var.send_feedback_prompt_email_task_schedule}"

  container_definition_template = "${module.rake_container_definition.template}"

  ecs_cluster_arn = "${aws_ecs_cluster.cluster.arn}"

  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn      = "${aws_iam_role.ecs_execution_role.arn}"
  event_role_arn     = "${aws_iam_role.scheduled_task_role.arn}"
}

module "import_schools_task" {
  source = "../scheduled-ecs-task"

  task_name        = "${var.ecs_service_web_task_name}_import_schools"
  task_description = "Import school data"
  task_command     = "${var.import_schools_task_command}"
  task_schedule    = "${var.import_schools_task_schedule}"

  container_definition_template = "${module.rake_container_definition.template}"

  ecs_cluster_arn = "${aws_ecs_cluster.cluster.arn}"

  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn      = "${aws_iam_role.ecs_execution_role.arn}"
  event_role_arn     = "${aws_iam_role.scheduled_task_role.arn}"
}

module "performance_platform_submit_task" {
  source = "../scheduled-ecs-task"

  task_name        = "${var.ecs_service_web_task_name}_performance_platform_submit"
  task_description = "Submit Performance Platform data"
  task_command     = "${var.performance_platform_submit_task_command}"
  task_schedule    = "${var.performance_platform_submit_task_schedule}"

  container_definition_template = "${module.performance_platform_rake_container_definition.template}"

  ecs_cluster_arn = "${aws_ecs_cluster.cluster.arn}"

  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn      = "${aws_iam_role.ecs_execution_role.arn}"
  event_role_arn     = "${aws_iam_role.scheduled_task_role.arn}"
}

module "vacancies_statistics_refresh_cache_task" {
  source = "../scheduled-ecs-task"

  task_name        = "${var.ecs_service_web_task_name}_vacancies_statistics_refresh_cache"
  task_description = "Refresh vacancy statistic cache"
  task_command     = "${var.vacancies_statistics_refresh_cache_task_command}"
  task_schedule    = "${var.vacancies_statistics_refresh_cache_task_schedule}"

  container_definition_template = "${module.google_api_rake_container_definition.template}"

  ecs_cluster_arn = "${aws_ecs_cluster.cluster.arn}"

  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn      = "${aws_iam_role.ecs_execution_role.arn}"
  event_role_arn     = "${aws_iam_role.scheduled_task_role.arn}"
}

module "update_database_records_in_big_query_task" {
  source = "../scheduled-ecs-task"

  task_name        = "${var.ecs_service_web_task_name}_update_database_records_in_big_query"
  task_description = "Update database records in Big Query"
  task_command     = "${var.update_database_records_in_big_query_task_command}"
  task_schedule    = "${var.update_database_records_in_big_query_task_schedule}"

  container_definition_template = "${module.rake_container_definition.template}"

  ecs_cluster_arn = "${aws_ecs_cluster.cluster.arn}"

  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn      = "${aws_iam_role.ecs_execution_role.arn}"
  event_role_arn     = "${aws_iam_role.scheduled_task_role.arn}"
}

module "export_tables_as_csv_to_big_query_task" {
  source = "../scheduled-ecs-task"

  task_name        = "${var.ecs_service_web_task_name}_export_tables_as_csv_to_big_query"
  task_description = "Exports CSV table data into Big Query tables"
  task_command     = "${var.export_tables_as_csv_to_big_query_task_command}"
  task_schedule    = "${var.export_tables_as_csv_to_big_query_task_schedule}"

  container_definition_template = "${module.rake_container_definition.template}"

  ecs_cluster_arn = "${aws_ecs_cluster.cluster.arn}"

  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn      = "${aws_iam_role.ecs_execution_role.arn}"
  event_role_arn     = "${aws_iam_role.scheduled_task_role.arn}"
}
