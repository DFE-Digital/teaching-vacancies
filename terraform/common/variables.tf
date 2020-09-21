variable region { default = "eu-west-2" }

variable s3_bucket_name { default = "terraform-state-002" }

variable route53_zones {
  type    = list
  default = ["teaching-jobs.service.gov.uk", "teaching-vacancies.service.gov.uk"]
}

locals {
  route53_zones = toset(var.route53_zones)
}
