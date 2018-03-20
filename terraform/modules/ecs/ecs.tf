/*====
ECR repository to store our Docker images
======*/
resource "aws_ecr_repository" "default" {
  name = "${var.project_name}-${var.environment}"
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
  name            = "${var.ecs_service_name}"
  iam_role        = "${aws_iam_role.ecs_role.arn}"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.web.arn}"
  desired_count   = "${var.ecs_service_task_count}"

  health_check_grace_period_seconds = 240
  deployment_minimum_healthy_percent = 50

  load_balancer {
    target_group_arn = "${var.aws_alb_target_group_arn}"
    container_name   = "${var.ecs_service_task_name}"
    container_port   = "${var.ecs_service_task_port}"
  }

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
data "template_file" "web_task" {
  template = "${file(var.ecs_service_task_definition_file_path)}"

  vars {
    image                    = "${aws_ecr_repository.default.repository_url}"
    entrypoint               = "${jsonencode(var.web_service_entrypoint)}"
    project_name             = "${var.project_name}"
    task_name                = "${var.ecs_service_task_name}"
    task_port                = "${var.ecs_service_task_port}"
    environment              = "${var.environment}"
    rails_env                = "${var.rails_env}"
    region                   = "${var.region}"
    log_group                = "${var.aws_cloudwatch_log_group_name}"
  }
}

/* import_schools task definition*/
data "template_file" "import_schools_task" {
  template = "${file(var.ecs_import_schools_task_definition_file_path)}"

  vars {
    image                    = "${aws_ecr_repository.default.repository_url}"
    project_name             = "${var.project_name}"
    task_name                = "${var.ecs_service_task_name}_import_schools"
    environment              = "${var.environment}"
    rails_env                = "${var.rails_env}"
    region                   = "${var.region}"
    log_group                = "${var.aws_cloudwatch_log_group_name}"
    entrypoint               = "${jsonencode(var.import_schools_entrypoint)}"
  }
}

/* vacancies_scrape task definition*/
data "template_file" "vacancies_scrape_task" {
  template = "${file(var.ecs_vacancies_scrape_task_definition_file_path)}"

  vars {
    image                    = "${aws_ecr_repository.default.repository_url}"
    project_name             = "${var.project_name}"
    task_name                = "${var.ecs_service_task_name}_vacancies_scrape"
    environment              = "${var.environment}"
    rails_env                = "${var.rails_env}"
    region                   = "${var.region}"
    log_group                = "${var.aws_cloudwatch_log_group_name}"
    entrypoint               = "${jsonencode(var.vacancies_scrape_entrypoint)}"
  }
}

resource "aws_ecs_task_definition" "web" {
  family                   = "${var.ecs_service_task_name}"
  container_definitions    = "${data.template_file.web_task.rendered}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

resource "aws_ecs_task_definition" "import_schools" {
  family                   = "${var.ecs_service_task_name}_import_schools"
  container_definitions    = "${data.template_file.import_schools_task.rendered}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

resource "aws_ecs_task_definition" "vacancies_scrape" {
  family                   = "${var.ecs_service_task_name}_vacancies_scrape"
  container_definitions    = "${data.template_file.vacancies_scrape_task.rendered}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

resource "aws_cloudwatch_event_rule" "vacancies_scrape_task_cron" {
  name                = "${var.ecs_service_task_name}_vacancies_scrape_cron"
  description         = "Run vacancies_scrape_task at specified cron time"
  schedule_expression = "${var.vacancies_scrape_schedule_expression}"
}

resource "aws_cloudwatch_event_target" "vacancies_scrape_task_cron_event" {
  target_id = "${var.ecs_service_task_name}_vacancies_scrape"
  rule      = "${aws_cloudwatch_event_rule.vacancies_scrape_task_cron.name}"
  arn       = "${aws_ecs_cluster.cluster.arn}"
  role_arn  = "${aws_iam_role.scheduled_task_role.arn}"

  ecs_target {
    task_count          = "1"
    task_definition_arn = "${aws_ecs_task_definition.vacancies_scrape.arn}"
  }
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
