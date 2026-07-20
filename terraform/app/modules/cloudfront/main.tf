resource "aws_cloudfront_distribution" "default" {
  origin {
    domain_name = var.cloudfront_origin_domain_name
    origin_id   = "${var.service_name}-${var.environment}-default-origin"

    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = var.offline_bucket_domain_name
    origin_id   = "${var.service_name}-${var.environment}-offline"
  }

  dynamic "custom_error_response" {
    for_each = local.cloudfront_custom_response
    content {
      error_code            = custom_error_response.key
      error_caching_min_ttl = custom_error_response.value.ttl
      response_code         = try(custom_error_response.value.response_code, null)
      response_page_path    = try(custom_error_response.value.page_path, null)
    }
  }

  enabled = true
  aliases = local.cloudfront_aliases

  ordered_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.service_name}-${var.environment}-offline"

    path_pattern = "${var.offline_bucket_origin_path}/*"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 60
    max_ttl     = 86400

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    path_pattern           = "/assets/*"
    target_origin_id       = "${var.service_name}-${var.environment}-default-origin"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.managed-caching-optimized.id
    compress               = var.enable_cloudfront_compress
  }

  ordered_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    path_pattern           = "/attachments/*"
    target_origin_id       = "${var.service_name}-${var.environment}-default-origin"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.managed-caching-optimized.id
  }

  ordered_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    path_pattern           = "/content-assets/*"
    target_origin_id       = "${var.service_name}-${var.environment}-default-origin"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.managed-caching-optimized.id
    compress               = var.enable_cloudfront_compress
  }

  default_cache_behavior {
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "${var.service_name}-${var.environment}-default-origin"
    cache_policy_id          = data.aws_cloudfront_cache_policy.Managed-CachingDisabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.Managed-AllViewer.id

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cloudfront_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = local.cloudfront_viewer_certificate_minimum_protocol_version
  }

  tags = {
    Name        = "${var.service_name}-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_route53_record" "cloudfront-a-records" {
  for_each = local.route53_zones_with_a_records
  zone_id  = data.aws_route53_zone.zones[each.value].zone_id
  name     = each.value
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.default.domain_name
    zone_id                = aws_cloudfront_distribution.default.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloudfront-cnames" {
  for_each = local.route53_zones_with_cnames
  zone_id  = data.aws_route53_zone.zones[each.value].zone_id
  name     = "${var.route53_cname_record}.${each.value}"
  type     = "CNAME"
  ttl      = "300"
  records  = ["${aws_cloudfront_distribution.default.domain_name}."]
}

resource "aws_wafv2_web_acl" "cloudfront-waf" {
  count    = var.enable_cloudfront_waf == true ? 1 : 0
  provider = aws.aws_us_east_1
  name     = "${var.service_name}-${var.environment}-waf"
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.service_name}-${var.environment}-allowed-traffic"
    sampled_requests_enabled   = true
  }

  lifecycle { ignore_changes = [rule] }
}

resource "aws_wafv2_web_acl_rule" "rate-limit" {
  count       = var.enable_cloudfront_waf == true ? 1 : 0
  name        = "${var.service_name}-${var.environment}-rate-limit"
  priority    = 1
  web_acl_arn = aws_wafv2_web_acl.cloudfront-waf[0].arn

  action {
    block {}
  }

  statement {
    rate_based_statement {
      limit              = var.waf_ip_rate_limit
      aggregate_key_type = "IP"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.service_name}-${var.environment}-blocked-ip-rate"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "sql-protection" {
  count       = var.enable_cloudfront_waf == true ? 1 : 0
  name        = "${var.service_name}-${var.environment}-sql-protection"
  priority    = 2
  web_acl_arn = aws_wafv2_web_acl.cloudfront-waf[0].arn

  action {
    block {}
  }

  statement {
    managed_rule_group_statement {
      vendor_name = "AWS"
      name        = "AWSManagedRulesSQLiRuleSet"
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.service_name}-${var.environment}-blocked-sql-protection"
    sampled_requests_enabled   = true
  }
}