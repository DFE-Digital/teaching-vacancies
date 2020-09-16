variable environment {
}

variable project_name {
}

variable cloudfront_origin_domain_name {
}

variable cloudfront_aliases {
  type = list(string)
}

variable cloudfront_certificate_arn {
}

variable offline_bucket_domain_name {
}

variable offline_bucket_origin_path {
}

variable domain {
}

variable default_header_list {
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
  ]
}

variable route53_zones {
  type = list
}

locals {
  is_production                = var.environment == "production"
  route53_prefix               = local.is_production ? "www" : var.environment
  route53_zones                = toset(var.route53_zones)
  route53_zones_with_a_records = local.is_production ? local.route53_zones : toset([])
  route53_zones_with_cnames    = local.route53_zones
}
