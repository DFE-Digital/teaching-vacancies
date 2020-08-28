terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.3.0"
    }
    cloudfoundry = {
      source  = "terraform.implied.local.mirror/cloudfoundrylocal/cloudfoundry"
      version = "0.12.2"
    }
  }
}
