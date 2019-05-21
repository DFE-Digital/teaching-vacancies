data "template_file" "container_definition" {
  template = "${var.container_definition_template}"

  vars {
    task_name  = "${var.task_name}"
    entrypoint = "${jsonencode(var.task_command)}"
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.task_name}_task"
  container_definitions    = "${data.template_file.container_definition.rendered}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "${var.cpu}"
  memory                   = "${var.memory}"
  execution_role_arn       = "${var.execution_role_arn}"
  task_role_arn            = "${var.task_role_arn}"
}
