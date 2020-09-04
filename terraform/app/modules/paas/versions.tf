terraform {

  required_providers {
    aws = {
      source  = "-/aws"
      version = ">= 2.70.0"
    }
    cloudfoundry = {
      source = "cloudfoundry-community/cloudfoundry"
      version = ">= 0.12.2"
    }
  }
}
