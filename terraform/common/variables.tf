variable region { default = "eu-west-2" }

variable s3_bucket_name { default = "terraform-state-002" }

locals {
  primary_zone_name   = "teaching-vacancies.service.gov.uk"
  secondary_zone_name = "teaching-jobs.service.gov.uk"
}
