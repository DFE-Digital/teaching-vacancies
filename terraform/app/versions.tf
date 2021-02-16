terraform {
  required_version = "~> 0.13.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.28.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "~> 0.13.0"
    }
    statuscake = {
      source  = "terraform-providers/statuscake"
      version = "~> 1.0.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.1.2"
    }
  }
}
