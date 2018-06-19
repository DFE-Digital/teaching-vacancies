variable "cluster_id" {}

variable "vpc_id" {}

variable "private_subnet_ids" {}

variable "engine_version" {
  default = "2.8.24"
}

variable "parameter_group_name" {
  default = "default.redis2.8"
}

variable "instance_type" {
  default = "cache.m3.medium"
}

variable "maintenance_window" {
  # SUN 01:00AM-02:00AM ET
  default = "sun:05:00-sun:06:00"
}

# tags
variable "tag_name" {}

variable "tag_environment" {}
variable "tag_team" {}
variable "tag_application" {}
variable "tag_contact-email" {}
variable "tag_customer" {}
