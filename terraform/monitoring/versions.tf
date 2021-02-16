terraform {
  required_version = "~> 0.13.1"
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.15.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "~> 0.13.0"
    }
  }
}
