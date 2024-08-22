terraform {
  required_version = "~> 1.5.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.29.0"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.2.2"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
  }
}
