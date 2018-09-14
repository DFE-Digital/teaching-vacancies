variable "environment" {}
variable "project_name" {}
variable "vpc_cidr" {}

variable "availability_zones" {
  type = "list"
}

variable "public_subnets_cidr" {
  type = "list"
}

variable "private_subnets_cidr" {
  type = "list"
}

variable "ssh_ips" {
  type = "list"
}

variable "region" {}
variable "image_id" {}
variable "instance_type" {}
variable "ecs_key_pair_name" {}
variable "load_balancer_check_path" {}
variable "alb_certificate_arn" {}
variable "aws_iam_ecs_instance_profile_name" {}

variable "asg_name" {}
variable "asg_max_size" {}
variable "asg_min_size" {}
variable "asg_desired_size" {}

variable "ecs_cluster_name" {}
variable "ecs_web_service_name" {}
