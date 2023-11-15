
variable "region" {
  default = "eu-west-2"
}

variable "environment" {}

# CloudFront


variable "distribution_list_aks" {
  description = "Define Cloudfront distributions for AKS environment with the attributes below"
  type = map(object({
    offline_bucket_domain_name    = string
    offline_bucket_origin_path    = string
    cloudfront_origin_domain_name = string
  }))
  default = {}
}

variable "enable_cloudfront_compress" {
  default = true
}

variable "route53_zones" {
  type    = list(any)
  default = ["teaching-jobs.service.gov.uk", "teaching-vacancies.service.gov.uk"]
}

# CloudWatch
variable "channel_list" {
  description = "Define slack channels CloudWatch should send alerts to"
  type = map(object({
    cloudwatch_slack_channel = string
  }))
  default = {}
}

# Documents S3 bucket
variable "documents_s3_bucket_force_destroy" {
  default = false
}

# School images and logos S3 bucket
variable "schools_images_logos_s3_bucket_force_destroy" {
  default = false
}

# Gov.UK PaaS

variable "app_docker_image" {
  default = "ghcr.io/dfe-digital/teaching-vacancies:placeholder"
}
variable "app_environment" {
  default = "dev"
}

variable "parameter_store_environment" {
  default = "dev"
}

variable "aks_web_app_start_command" {
  default = ["/bin/sh", "-c", "bundle exec rake db:migrate:ignore_concurrent_migration_exceptions && rails s"]
}
variable "paas_sso_passcode" {
  default = ""
}
# Statuscake
variable "statuscake_alerts" {
  description = "Define Statuscake alerts with the attributes below"
  default     = {}
}

# AKS
variable "cluster" {
  description = "AKS cluster where this app is deployed. Either 'test' or 'production'"
}
variable "enable_monitoring" {
  default     = false
  description = "Enable monitoring and alerting"
}
variable "deploy_azure_backing_services" {
  default     = true
  description = "Deploy real Azure backing services like databases, as opposed to containers inside of AKS"
}
variable "azure_enable_backup_storage" {
  default     = true
  description = "Create storage account for database backup"
}
variable "namespace" {
  description = "AKS namespace where this app is deployed"
}
variable "azure_resource_prefix" {
  description = "Standard resource prefix. Usually s189t01 (test) or s189p01 (production)"
}
variable "config_short" {
  description = "Short name of the environment configuration, e.g. dv, st, pd..."
}
variable "service_short" {
  description = "Short name to identify the service. Up to 6 charcters."
}
variable "enable_postgres_ssl" {
  default     = true
  description = "Enforce SSL connection from the client side"
}
variable "postgres_flexible_server_sku" {
  default     = "B_Standard_B1ms"
  description = "Postgres database instance type"
}
variable "postgres_enable_high_availability" {
  default     = false
  description = "Deploy postgres as a cluster across multiple availability zones"
}
variable "redis_cache_capacity" {
  default     = 1
  description = "The size of the Redis cache to deploy e.g. 1 for P1"
}
variable "redis_cache_family" {
  default     = "C"
  description = "The SKU family/pricing group to use. e.g. P for P1"
}
variable "redis_cache_sku_name" {
  default     = "Standard"
  description = "The SKU of Redis to use. Possible values are Basic, Standard and Premium."
}
variable "redis_queue_capacity" {
  default     = 1
  description = "The size of the Redis cache to deploy e.g. 1 for P1"
}
variable "redis_queue_family" {
  default     = "C"
  description = "The SKU family/pricing group to use. e.g. P for P1"
}
variable "redis_queue_sku_name" {
  default     = "Standard"
  description = "The SKU of Redis to use. Possible values are Basic, Standard and Premium."
}
variable "add_database_name_suffix" {
  default     = false
  description = "Add optional suffix to the postgres instance name to differentiate between environments"
}
variable "aks_web_app_instances" {
  default = 1
}
variable "aks_worker_app_instances" {
  default = 1
}
variable "aks_worker_app_memory" {
  default = "1Gi"
}

variable "aks_route53_a_records" {
  default = []
}

variable "aks_route53_cname_record" {
  default = "not-in-use"
}

variable "azure_maintenance_window" { default = null }


locals {
  paas_api_url               = "https://api.london.cloud.service.gov.uk"
  app_env_values             = yamldecode(file("${path.module}/../workspace-variables/${var.app_environment}_app_env.yml"))
  infra_secrets              = yamldecode(data.aws_ssm_parameter.infra_secrets.value)
  is_production              = var.environment == "production"
  web_external_hostnames_aks = concat([for zone in var.route53_zones : "${var.aks_route53_cname_record}.${zone}"], var.aks_route53_a_records)
  service_name               = "teaching-vacancies"
  service_abbreviation       = "tv"
}
