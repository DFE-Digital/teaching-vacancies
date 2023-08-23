provider "aws" {
  region = var.region
}

# The two aliases below are passed to the Cloudfront module
# Certificates for Cloudfront must be in us_east_1 region

provider "aws" {
  alias  = "default"
  region = var.region
}

provider "aws" {
  alias  = "aws_us_east_1"
  region = "us-east-1"
}
provider "azurerm" {
  features {}

  skip_provider_registration = true
}

provider "kubernetes" {
  host                   = module.cluster_data.kubernetes_host
  client_certificate     = module.cluster_data.kubernetes_client_certificate
  client_key             = module.cluster_data.kubernetes_client_key
  cluster_ca_certificate = module.cluster_data.kubernetes_cluster_ca_certificate
}
