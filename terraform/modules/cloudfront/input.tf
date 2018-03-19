variable "environment" {}
variable "project_name" {}
variable "cloudfront_origin_domain_name" {}

variable "cloudfront_aliases" {
  type = "list"
}

variable "cloudfront_certificate_arn" {}
