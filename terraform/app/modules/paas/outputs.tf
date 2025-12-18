# Azure Storage Outputs (for future app integration)
output "documents_azure_storage_account_name" {
  value     = var.azure_storage_documents_enabled ? module.documents_azure_storage[0].name : null
  sensitive = false
}

output "documents_azure_storage_connection_string" {
  value     = var.azure_storage_documents_enabled ? module.documents_azure_storage[0].primary_connection_string : null
  sensitive = true
}

output "documents_azure_storage_access_key" {
  value     = var.azure_storage_documents_enabled ? module.documents_azure_storage[0].primary_access_key : null
  sensitive = true
}

output "images_logos_azure_storage_account_name" {
  value     = var.azure_storage_images_logos_enabled ? module.images_logos_azure_storage[0].name : null
  sensitive = false
}

output "images_logos_azure_storage_connection_string" {
  value     = var.azure_storage_images_logos_enabled ? module.images_logos_azure_storage[0].primary_connection_string : null
  sensitive = true
}

output "images_logos_azure_storage_access_key" {
  value     = var.azure_storage_images_logos_enabled ? module.images_logos_azure_storage[0].primary_access_key : null
  sensitive = true
}
