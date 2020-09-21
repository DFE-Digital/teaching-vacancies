data aws_caller_identity current {}

data aws_s3_bucket cloudfront_logs {
  bucket = "${data.aws_caller_identity.current.account_id}-tv-cloudfront-logs"
}

data aws_route53_zone zones {
  for_each = local.route53_zones
  name     = each.value
}
