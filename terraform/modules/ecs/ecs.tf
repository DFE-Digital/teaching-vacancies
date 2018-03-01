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

  deployment_minimum_healthy_percent = 50

  load_balancer {
    target_group_arn  = "${var.aws_alb_target_group_arn}"
    container_name    = "${var.ecs_service_task_name}"
    container_port    = "${var.ecs_service_task_port}"
  }

  depends_on = ["aws_iam_role.ecs_role"]
}

/*====
ECS task definitions
======*/

/* the task definition for the web service */
data "template_file" "web_task" {
  template = "${file(var.ecs_service_task_definition_file_path)}"

  vars {
    image               = "${aws_ecr_repository.default.repository_url}"
    http_pass           = "${var.http_pass}"
    http_user           = "${var.http_user}"
    google_maps_api_key = "${var.google_maps_api_key}"
    secret_key_base     = "${var.secret_key_base}"
    project_name        = "${var.project_name}"
    task_name           = "${var.ecs_service_task_name}"
    task_port           = "${var.ecs_service_task_port}"
    environment         = "${var.environment}"
    region              = "${var.region}"
    log_group           = "${var.aws_cloudwatch_log_group_name}"
    database_user       = "${var.rds_username}"
    database_password   = "${var.rds_password}"
    database_url        = "${var.rds_address}"
    elastic_search_url  = "${var.es_address}"
  }
}

resource "aws_ecs_task_definition" "web" {
  family                   = "${var.ecs_service_task_name}"
  container_definitions    = "${data.template_file.web_task.rendered}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "256"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

/*====
IAM service role
======*/
data "aws_iam_policy_document" "ecs_service_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
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
  name                = "${var.project_name}-${var.environment}-ecs-instance-role"
  path                = "/"
  assume_role_policy  = "${data.aws_iam_policy_document.ecs-instance-policy.json}"
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
