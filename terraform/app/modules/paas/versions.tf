terraform {
  required_version = ">= 0.13.1"
  required_providers {
    aws = {
      source  = "-/aws"
      version = "~> 3.28.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = ">= 0.13.0"
    }
  }
}
