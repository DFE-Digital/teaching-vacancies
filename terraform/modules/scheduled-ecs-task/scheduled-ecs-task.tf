module "task" {
  source = "../ecs-task"

  task_name    = "${var.task_name}"
  task_command = "${var.task_command}"

  container_definition_template = "${var.container_definition_template}"

  cpu    = "${var.cpu}"
  memory = "${var.memory}"

  execution_role_arn = "${var.execution_role_arn}"
  task_role_arn      = "${var.task_role_arn}"
}

resource "aws_cloudwatch_event_rule" "task" {
  name                = "${module.task.family}"
  description         = "${var.task_description} at a scheduled time"
  schedule_expression = "${var.task_schedule}"
}

resource "aws_cloudwatch_event_target" "task" {
  target_id = "${module.task.family}"
  rule      = "${aws_cloudwatch_event_rule.task.name}"
  arn       = "${var.ecs_cluster_arn}"
  role_arn  = "${var.event_role_arn}"

  ecs_target {
    task_count          = 1
    task_definition_arn = "${module.task.arn}"
  }
}
