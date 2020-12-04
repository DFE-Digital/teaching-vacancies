provider aws {
  region = var.region
}

terraform {

  backend "s3" {
    bucket  = "terraform-state-002"
    key     = "teaching-vacancies/terraform-common.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}


module domains {
  source = "./modules/domains"

  primary_zone_name   = local.primary_zone_name
  secondary_zone_name = local.secondary_zone_name

}
