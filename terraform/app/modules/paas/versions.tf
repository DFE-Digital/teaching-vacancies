terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = {
      source  = "-/aws"
      version = ">= 3.8.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = ">= 0.13.0"
    }
  }
}
