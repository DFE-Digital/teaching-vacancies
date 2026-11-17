module "infrastructure_secrets" {
  source = "./vendor/modules/aks//aks/secrets"

  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  key_vault_short       = "inf"
}

variable "airbyte_enabled" {
  type        = bool
  default     = false
  description = "Create the Airbyte source, destination and connection"
}

variable "connection_status" {
  type        = string
  default     = "inactive"
  description = "Airbyte connection status, either active or inactive"
}

locals {
  airbyte_server_url = "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}"
}
