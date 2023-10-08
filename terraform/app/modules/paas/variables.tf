variable "environment" {
}

variable "app_docker_image" {
}

variable "app_env_values" {
}

variable "parameter_store_environment" {
  default = "dev"
}

variable "documents_s3_bucket_force_destroy" {
  default = false
}

variable "schools_images_logos_s3_bucket_force_destroy" {
  default = false
}

variable "service_name" {
}

variable "service_abbreviation" {
}

variable "aks_web_app_instances" {
  default = 1
}

variable "aks_web_app_start_command" {
}

variable "aks_worker_app_instances" {
}

variable "aks_worker_app_memory" {
}

variable "web_external_hostnames_aks" {
  type = list(string)
}

variable "azure_enable_backup_storage" {
  default     = true
  description = "Create storage account for database backup"
}
variable "enable_monitoring" {
  description = "Enable monitoring and alerting"
  default     = false
}

# AKS
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
variable "deploy_azure_backing_services" {
  default     = true
  description = "Deploy real Azure backing services like databases, as opposed to containers inside of AKS"
}
variable "cluster" {
  description = "AKS cluster where this app is deployed. Either 'test' or 'production'"
}
variable "statuscake_alerts" {
  type    = map(any)
  default = {}
}
variable "enable_postgres_ssl" {
  default     = true
  description = "Enforce SSL connection from the client side"
}

variable "postgres_flexible_server_sku" {}
variable "postgres_enable_high_availability" {}
variable "redis_cache_capacity" {}
variable "redis_cache_family" {}
variable "redis_cache_sku_name" {}
variable "redis_queue_capacity" {}
variable "redis_queue_family" {}
variable "redis_queue_sku_name" {}
variable "add_database_name_suffix" {}

locals {
  postgres_ssl_mode = var.enable_postgres_ssl ? "require" : "disable"

  app_env_api_keys = merge(
    yamldecode(data.aws_ssm_parameter.app_env_api_key_big_query.value),
    yamldecode(data.aws_ssm_parameter.app_env_api_key_google.value)
  )
  app_env_secrets = yamldecode(data.aws_ssm_parameter.app_env_secrets.value)
  app_env_documents_bucket_credentials = {
    DOCUMENTS_S3_BUCKET         = local.documents_s3_bucket_name
    DOCUMENTS_ACCESS_KEY_ID     = aws_iam_access_key.documents_s3_bucket_access_key.id
    DOCUMENTS_ACCESS_KEY_SECRET = aws_iam_access_key.documents_s3_bucket_access_key.secret
  }
  app_env_schools_images_logos_s3_bucket_credentials = {
    SCHOOLS_IMAGES_LOGOS_S3_BUCKET         = local.schools_images_logos_s3_bucket_name
    SCHOOLS_IMAGES_LOGOS_ACCESS_KEY_ID     = aws_iam_access_key.schools_images_logos_s3_bucket_access_key.id
    SCHOOLS_IMAGES_LOGOS_ACCESS_KEY_SECRET = aws_iam_access_key.schools_images_logos_s3_bucket_access_key.secret
  }
  app_env_domain = { "DOMAIN" = "teaching-vacancies-${var.environment}.london.cloudapps.digital" }
  app_environment = merge(
    local.app_env_api_keys,
    local.app_env_secrets,
    local.app_env_documents_bucket_credentials,
    local.app_env_schools_images_logos_s3_bucket_credentials,
    local.app_env_domain,
    var.app_env_values #Because of merge order, if present, the value of DOMAIN in .tfvars.json will overwrite app_env_domain
  )

  # S3 bucket name uses abbreviation so we don't run into 63 character bucket name limit
  documents_s3_bucket_name            = "${data.aws_caller_identity.current.account_id}-${var.service_abbreviation}-attachments-documents-${var.environment}"
  schools_images_logos_s3_bucket_name = "${data.aws_caller_identity.current.account_id}-${var.service_abbreviation}-attachments-images-logos-${var.environment}"
  web_app_name                        = "${var.service_name}-${var.environment}"
  worker_app_start_command            = "bundle exec sidekiq -C config/sidekiq.yml"
  worker_app_name                     = "${var.service_name}-worker-${var.environment}"

  postgres_extensions = { enable_extensions = ["pgcrypto", "fuzzystrmatch", "plpgsql", "pg_trgm", "postgis"] }

  # AKS
  # Use the AKS ingress domain by default. Override with the DOMAIN variable is present
  # The TEMP_DOMAIN variable takes precedence during the migration from PaaS to AKS
  web_app_aks_domain = "teaching-vacancies-${var.environment}.${module.cluster_data.ingress_domain}"
  web_app_domain = try(
    var.app_env_values["TEMP_DOMAIN"],
    try(var.app_env_values["DOMAIN"], local.web_app_aks_domain)
  )
  web_app_dfe_sign_in_redirect_url = try(
    var.app_env_values["TEMP_DFE_SIGN_IN_REDIRECT_URL"],
    var.app_env_values["DFE_SIGN_IN_REDIRECT_URL"],
    null
  )
  dfe_sign_in_map = (local.web_app_dfe_sign_in_redirect_url != null ?
    { DFE_SIGN_IN_REDIRECT_URL = local.web_app_dfe_sign_in_redirect_url } :
    {}
  )
  disable_emails_map = (contains(keys(var.app_env_values), "TEMP_DISABLE_EMAILS") ?
    { DISABLE_EMAILS = var.app_env_values["TEMP_DISABLE_EMAILS"] } :
    {}
  )

  disable_analytics_map = (contains(keys(var.app_env_values), "TEMP_BIGQUERY_DATASET") ?
    { BIGQUERY_DATASET = var.app_env_values["TEMP_BIGQUERY_DATASET"] } :
    {}
  )

  database_name_suffix = var.add_database_name_suffix ? "${var.environment}" : null
}
