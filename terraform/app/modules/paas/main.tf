# Azure Storage Account for Documents
module "documents_azure_storage" {
  source = "../../vendor/modules/aks//aks/storage_account"

  name                  = "doc"
  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  # Redundancy: ZRS for production, LRS for non-prod (module enforced)
  production_replication_type = var.azure_storage_production_replication_type

  # Security settings
  public_network_access_enabled     = true # Required for app access
  infrastructure_encryption_enabled = false

  # Versioning and retention
  blob_versioning_enabled         = var.azure_storage_blob_versioning_enabled
  blob_delete_retention_days      = var.azure_storage_blob_delete_retention_days
  container_delete_retention_days = var.azure_storage_blob_delete_retention_days
  blob_delete_after_days          = var.azure_storage_blob_delete_after_days

  # Container for documents
  containers = [
    { name = "documents" }
  ]

  create_encryption_scope = false

  # CORS rules for Rails Direct Uploads (browser to storage)
  cors_rules = [
    {
      allowed_headers    = ["Content-Type", "Content-MD5", "Content-Disposition", "x-ms-blob-content-disposition", "x-ms-blob-type"]
      allowed_methods    = ["PUT"]
      allowed_origins    = var.azure_storage_cors_allowed_origins
      exposed_headers    = []
      max_age_in_seconds = 3600
    }
  ]
}

# Azure Storage Account for School Images/Logos
module "images_logos_azure_storage" {
  source = "../../vendor/modules/aks//aks/storage_account"

  name                  = "img"
  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  # Redundancy: ZRS for production, LRS for non-prod (module enforced)
  production_replication_type = var.azure_storage_production_replication_type

  # Security settings
  public_network_access_enabled     = true # Required for app access
  infrastructure_encryption_enabled = false

  # Versioning and retention
  blob_versioning_enabled         = var.azure_storage_blob_versioning_enabled
  blob_delete_retention_days      = var.azure_storage_blob_delete_retention_days
  container_delete_retention_days = var.azure_storage_blob_delete_retention_days
  blob_delete_after_days          = var.azure_storage_blob_delete_after_days

  # Container for images/logos
  containers = [
    { name = "images-logos" }
  ]

  create_encryption_scope = false
}
