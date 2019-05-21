data "template_file" "container_definition_template" {
  template = "${file(var.template_file_path)}"

  vars {
    image                    = "${var.image}"
    secret_key_base          = "${var.secret_key_base}"
    project_name             = "${var.project_name}"
    environment              = "${var.environment}"
    rails_env                = "${var.rails_env}"
    rails_max_threads        = "${var.rails_max_threads}"
    redis_cache_url          = "${var.redis_cache_url}"
    redis_queue_url          = "${var.redis_queue_url}"
    region                   = "${var.region}"
    log_group                = "${var.log_group}"
    database_user            = "${var.database_user}"
    database_password        = "${var.database_password}"
    database_url             = "${var.database_url}"
    elastic_search_url       = "${var.elastic_search_url}"
    aws_elasticsearch_region = "${var.aws_elasticsearch_region}"
    aws_elasticsearch_key    = "${var.aws_elasticsearch_key}"
    aws_elasticsearch_secret = "${var.aws_elasticsearch_secret}"
    feature_import_vacancies = "${var.feature_import_vacancies}"

    pp_transactions_by_channel_token = "${var.pp_transactions_by_channel_token}"
    pp_user_satisfaction_token       = "${var.pp_user_satisfaction_token}"

    # We are creating a partially rendered template from a template file.
    # These values are escaped to create a new template with the same vars.

    task_name  = "$${task_name}"
    entrypoint = "$${entrypoint}"
  }
}
