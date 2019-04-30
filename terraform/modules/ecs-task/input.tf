variable "task_name" {}

variable "task_command" {
  type = "list"
}

variable "container_definition_template" {}

variable "execution_role_arn" {}
variable "task_role_arn" {}

variable "cpu" {
  default = 256
}

variable "memory" {
  default = 512
}
