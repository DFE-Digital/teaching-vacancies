variable "aws_account_id" {
  description = "AWS account ID"
}

variable "repository_url" {
  description = "GitHub repository"
  default     = "https://github.com/dxw/terraform-10000ft-scheduling-dashboard.git"
}

variable "github_token" {
  description = "GitHub auth token that can read from the GitHub repository"
}

variable "region" {}

# Alphanumeric characters only as some resources like RDS require it
variable "project_name" {}

# Network
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  default = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "trusted_ips" {
  type = "list"
}

# EC2
variable "load_balancer_check_path" {
  default = "/"
}

variable "asg_name" {
  default = "scheduling-default-asg"
}

variable "asg_max_size" {
  description = "The maximum EC2 count for the default autoscaling group policy"
  default = 1
}

variable "asg_min_size" {
  description = "The minimum EC2 count for the default autoscaling group policy"
  default = 1
}

variable "asg_desired_size" {
  description = "The prefferd EC2 count for the default autoscaling group policy"
  default = 1
}

# ECS
variable "ecs_cluster_name" {}
variable "ecs_service_name" {
  default = "scheduling-web"
}

variable "ecs_service_task_name" {
  default = "web"
}

variable "ecs_service_task_count" {
  description = "The number of containers to run for this service"
  default = 1
}

variable "ecs_service_task_port" {
  description = "The port for this service to expose"
  default = 3000
}

variable "ecs_service_task_definition_file_path" {
  default = "./web_task_definition.json"
}

variable "buildspec_location" {
  default = "./buildspec.yml"
}

# RDS
variable "rds_engine" {
  default     = "postgres"
  description = "Engine type, example values mysql, postgres"
}

variable "rds_engine_version" {
  description = "Engine version"

  default = {
    mysql    = "5.6.22"
    postgres = "9.6.6"
  }
}
variable "rds_storage_gb" {}
variable "rds_username" {}
variable "rds_password" {}
variable "rds_instance" {
  default = "db.t2.micro"
}

# Make sure this AWS AMI is valid for the chosen region.
variable "image_id" {
  default = "ami-67cbd003"
}

variable "instance_type" {
  description = "The size of the EC2 instances to use"
  default = "t2.micro"
}

variable "ecs_key_pair_name" {
  default = "hippers-fatrascal"
}

variable "http_pass"            {}
variable "http_user"            {}
variable "google_maps_api_key"  {}
variable "secret_key_base"      {}
