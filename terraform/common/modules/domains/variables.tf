variable primary_zone_name {
  description = "Primary DNS zone name and Common Name for certificate"
  type        = string
  default     = ""
}

variable secondary_zone_name {
  description = "Secondary DNS zone name"
  type        = string
  default     = ""
}

locals {
  route53_zones = toset([var.primary_zone_name, var.secondary_zone_name])

  subject_alternative_names = [
    "*.${var.primary_zone_name}",
    var.secondary_zone_name,
    "*.${var.secondary_zone_name}",
  ]

  secondary_zone_bing_validation_record_name = "c0e62f5bc2cefff55a28530903b208b7"

  validations = {
    for validation_option in aws_acm_certificate.cert.domain_validation_options :
    validation_option.domain_name => validation_option
  }
}
