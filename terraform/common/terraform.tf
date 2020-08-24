provider aws {
  region = var.region
}

terraform {
  required_version = ">= 0.12.29"

  backend "s3" {
    bucket  = "terraform-state-002"
    key     = "tvs/terraform-common.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}
