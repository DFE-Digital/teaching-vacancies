terraform {
  required_version = "~> 1.2.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.45.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "~> 0.14"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.0.3"
    }
  }
}
