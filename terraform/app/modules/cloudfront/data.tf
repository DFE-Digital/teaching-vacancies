data "aws_caller_identity" "current" {}

data "aws_route53_zone" "zones" {
  for_each = local.route53_zones
  name     = each.value
}

data "aws_acm_certificate" "cloudfront_cert" {
  domain      = local.cloudfront_cert_cn
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
  provider    = aws.aws_us_east_1
}

data "aws_cloudfront_cache_policy" "managed-caching-optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "Managed-CachingDisabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "Managed-AllViewer" {
  name = "Managed-AllViewer"
}
