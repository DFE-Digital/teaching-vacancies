variable "environment" {}
variable "project_name" {}
variable "cloudfront_origin_domain_name" {}

variable "cloudfront_aliases" {
  type = "list"
}

variable "cloudfront_certificate_arn" {}
variable "offline_bucket_domain_name" {}
variable "offline_bucket_origin_path" {}
variable "domain" {}
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
      ]
}
