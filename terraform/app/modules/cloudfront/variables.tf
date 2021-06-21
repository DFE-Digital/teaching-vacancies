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


variable "default_header_list" {
  default = [
    "Authorization",
    "Origin",
    "Referer",
    "Accept",
    "Accept-Charset",
    "Accept-DateTime",
    "Accept-Encoding",
    "Accept-Language",
    "CloudFront-Forwarded-Proto",
    "User-Agent",
    "Host"
  ]
}

variable "route53_zones" {
  type = list(any)
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
  cloudfront_viewer_certificate_minimum_protocol_version = "TLSv1.2_2018"
  cloudfront_path_pattern                                = { pattern = { path = "/packs/*" }, pattern2 = { path = "/attachment*" } }
}
