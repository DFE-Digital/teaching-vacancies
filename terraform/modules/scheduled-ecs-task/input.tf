variable "task_name" {}
variable "task_description" {}

variable "task_command" {
  type = "list"
}

variable "task_schedule" {}

variable "container_definition_template" {}

variable "ecs_cluster_arn" {}

variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "event_role_arn" {}

variable "cpu" {
  default = 256
}

variable "memory" {
  default = 512
}
