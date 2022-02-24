variable "environment" {
}

variable "service_name" {
}

variable "cloudfront_origin_domain_name" {
}

variable "offline_bucket_domain_name" {
}

variable "offline_bucket_origin_path" {
}

variable "route53_zones" {
  type = list(any)
}

variable "enable_cloudfront_compress" {
  default = true
}

variable "is_production" {}
variable "route53_cname_record" {}
variable "route53_a_records" {}

locals {
  route53_zones                                          = toset(var.route53_zones)
  route53_zones_with_a_records                           = var.is_production ? local.route53_zones : toset([])
  route53_zones_with_cnames                              = local.route53_zones
  cloudfront_cert_cn                                     = "${var.service_name}.service.gov.uk"
  domain                                                 = var.is_production ? local.cloudfront_cert_cn : "${var.environment}.${local.cloudfront_cert_cn}"
  cloudfront_aliases_cnames                              = [for zone in var.route53_zones : "${var.route53_cname_record}.${zone}"]
  cloudfront_aliases                                     = concat(var.route53_a_records, local.cloudfront_aliases_cnames)
  cloudfront_viewer_certificate_minimum_protocol_version = "TLSv1.2_2021"
  cloudfront_custom_response = {
    404 = { ttl = "10" },
    500 = { ttl = "60", response_code = "500", page_path = "${var.offline_bucket_origin_path}/index.html" },
    502 = { ttl = "60", response_code = "502", page_path = "${var.offline_bucket_origin_path}/index.html" },
    503 = { ttl = "60", response_code = "503", page_path = "${var.offline_bucket_origin_path}/index.html" },
    504 = { ttl = "60", response_code = "504", page_path = "${var.offline_bucket_origin_path}/index.html" }
  }
}
