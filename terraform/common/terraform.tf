provider aws {
  region = var.region
}

terraform {

  backend "s3" {
    bucket  = "terraform-state-002"
    key     = "tvs/terraform-common.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}
