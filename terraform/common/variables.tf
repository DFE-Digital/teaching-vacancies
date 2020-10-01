variable region { default = "eu-west-2" }

variable s3_bucket_name { default = "terraform-state-002" }

variable route53_records {
  type = map(object({
    zone_name    = string
    record_name  = string
    record_ttl   = string
    record_type  = string
    record_value = string
  }))
  default = {
    "jobs-CAA" = {
      zone_name    = "teaching-jobs.service.gov.uk"
      record_name  = "teaching-jobs.service.gov.uk"
      record_ttl   = "300"
      record_type  = "CAA"
      record_value = "0 issue \"amazon.com\""
    }
    "jobs-SPF" = {
      zone_name    = "teaching-jobs.service.gov.uk"
      record_name  = "teaching-jobs.service.gov.uk"
      record_ttl   = "300"
      record_type  = "TXT"
      record_value = "v=spf1 -all"
    }
    "jobs-DMARC" = {
      zone_name    = "teaching-jobs.service.gov.uk"
      record_name  = "_dmarc.teaching-jobs.service.gov.uk"
      record_ttl   = "300"
      record_type  = "TXT"
      record_value = "v=DMARC1; p=reject; sp=reject; rua=mailto:dmarc-rua@dmarc.service.gov.uk; ruf=mailto:dmarc-ruf@dmarc.service.gov.uk"
    }
    "jobs-bing" = {
      zone_name    = "teaching-jobs.service.gov.uk"
      record_name  = "c0e62f5bc2cefff55a28530903b208b7.teaching-jobs.service.gov.uk"
      record_ttl   = "300"
      record_type  = "CNAME"
      record_value = "verify.bing.com."
    }
    "vacancies-CAA" = {
      zone_name    = "teaching-vacancies.service.gov.uk"
      record_name  = "teaching-vacancies.service.gov.uk"
      record_ttl   = "300"
      record_type  = "CAA"
      record_value = "0 issue \"amazon.com\""
    }
    "vacancies-SPF" = {
      zone_name    = "teaching-vacancies.service.gov.uk"
      record_name  = "teaching-vacancies.service.gov.uk"
      record_ttl   = "300"
      record_type  = "TXT"
      record_value = "v=spf1 -all"
    }
    "vacancies-DMARC" = {
      zone_name    = "teaching-vacancies.service.gov.uk"
      record_name  = "_dmarc.teaching-vacancies.service.gov.uk"
      record_ttl   = "300"
      record_type  = "TXT"
      record_value = "v=DMARC1; p=reject; sp=reject; rua=mailto:dmarc-rua@dmarc.service.gov.uk; ruf=mailto:dmarc-ruf@dmarc.service.gov.uk"
    }
  }
}


variable route53_zones {
  type    = list
  default = ["teaching-jobs.service.gov.uk", "teaching-vacancies.service.gov.uk"]
}

locals {
  route53_zones = toset(var.route53_zones)
}
