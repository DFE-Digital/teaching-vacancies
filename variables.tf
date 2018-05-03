variable "aws_account_id" {
  description = "AWS account ID"
}

variable "github_token" {
  description = "GitHub auth token that can read from the GitHub repository"
}

variable "project_name" {
  description = "This name will be used to identify all AWS resources. The workspace name will be suffixed. Alphanumeric characters only due to RDS."
}

variable "buildspec_location" {
  description = "AWS Codebuild will look for this file to tell it how to build this project"
  default     = "./buildspec.yml"
}

variable "git_branch_to_track" {
  description = "Git branch to listen for code changes on and auto deploy"
  default     = "master"
}

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

variable "ssh_ips" {
  description = "IPs with a degree of trust "
  type        = "list"
}

# EC2

variable "region" {
  default = "eu-west-2"
}

# EC2
variable "availability_zones" {
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "ecs_key_pair_name" {
  description = "This key will be placed onto the machines by Terraform to allow SSH"
}

variable "image_id" {
  default = "ami-67cbd003" # Make sure this AWS AMI is valid for the chosen region.
}

variable "ecs_instance_type" {
  description = "The size of the EC2 instances to use"
  default     = "t2.micro"
}

variable "asg_name" {
  default = "scheduling-default-asg"
}

variable "asg_max_size" {
  description = "The maximum EC2 count for the default autoscaling group policy"
  default     = 1
}

variable "asg_min_size" {
  description = "The minimum EC2 count for the default autoscaling group policy"
  default     = 1
}

variable "asg_desired_size" {
  description = "The prefferd EC2 count for the default autoscaling group policy"
  default     = 1
}

variable "alb_certificate_arn" {
  description = "The certificate ARN to attach to the ALB's HTTPS listener"
}

# ECS
variable "ecs_cluster_name" {}

variable "ecs_service_name" {
  default = "default-web"
}

variable "ecs_service_task_name" {
  default = "web"
}

variable "ecs_service_task_count" {
  description = "The number of containers to run for this service"
  default     = 1
}

variable "ecs_service_task_port" {
  description = "The port this application is listening on (ALB will map these with ephemeral port numbers)"
  default     = 3000
}

# ECS Tasks
variable "ecs_service_web_container_definition_file_path" {
  description = "Container definition for the web task"
  default     = "./web_container_definition.json"
}

variable "ecs_service_rake_container_definition_file_path" {
  description = "Container definition for rake tasks"
  default     = "./rake_container_definition.json"
}

variable "ecs_service_logspout_container_definition_file_path" {
  description = "Logspout container definition"
  default     = "./logspout_container_definition.json"
}

variable "import_schools_task_command" {
  description = "The Entrypoint for the import_schools task"
  default     = ["rake", "data:schools:import"]
}

variable "vacancies_scrape_task_command" {
  description = "The Entrypoint for the vacancies_scrape task"
  default     = ["rake", "vacancies:data:scrape"]
}

variable "sessions_trim_task_command" {
  description = "The Entrypoint for trimming old sessions"
  default     = ["rake", "db:sessions:trim"]
}

variable "update_pay_scale_task_command" {
  description = "The Entrypoint for the update_pay_scale task"
  default     = ["rake", "data:update:pay_scale"]
}

variable "update_vacancies_task_command" {
  description = "The Entrypoint for the update_vacancies task"
  default     = ["rake", "vacancies:data:update"]
}

variable "vacancies_scrape_task_schedule" {
  description = "vacancies_scrape schedule expression - https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  default     = "rate(60 minutes)"
}

variable "sessions_trim_task_schedule" {
  description = "sessions_trim schedule expression - https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  default     = "rate(1 day)"
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

variable "rds_instance_type" {
  default = "db.t2.micro"
}

# Elastic search
variable "es_version" {
  description = "Amazon Elasticsearch Service currently supports Elasticsearch versions 6.0, 5.5, 5.3, 5.1, 2.3, and 1.5."
  default     = "6.0"
}

variable "es_instance_count" {
  default = 2
}

variable "es_instance_type" {
  default = "t2.small.elasticsearch"
}

# CloudFront
variable "cloudfront_certificate_arn" {
  description = "Create and verify a certificate through AWS Certificate Manager to acquire this"
}

variable "cloudfront_aliases" {
  description = "Match this value to the alias associated with the cloudfront_certificate_arn, eg. tvs.staging.dxw.net"
  type        = "list"
}

variable "offline_bucket_domain_name" {}
variable "offline_bucket_origin_path" {}

# Cloudwatch
variable "cloudwatch_slack_hook_url" {
  description = "The slack hook that cloudwatch alarms are sent to"
}

variable "cloudwatch_slack_channel" {
  description = "The slack channel that cloudwatch alarms are sent to"
}

variable "cloudwatch_ops_genie_api_key" {
  description = "The ops genie api key for sending alerts to ops genie"
}

# Application
variable "rails_env" {}

variable "override_school_urn" {}
variable "http_user" {}
variable "http_pass" {}
variable "aad_client_id" {}
variable "aad_tenant" {}
variable "google_maps_api_key" {}
variable "google_analytics" {}
variable "secret_key_base" {}

variable "load_balancer_check_path" {
  default = "/"
}

variable "rollbar_access_token" {}

variable "logspout_command" {
  type = "list"
}
