resource "aws_cloudfront_distribution" "default" {
  origin {
    domain_name = "${var.cloudfront_origin_domain_name}"
    origin_id   = "${var.project_name}-${var.environment}-default-origin"

    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  origin {
    domain_name = "${var.offline_bucket_domain_name}"
    origin_id   = "${var.project_name}-${var.environment}-offline"
  }

  custom_error_response {
    error_code            = "503"
    error_caching_min_ttl = "60"
    response_code         = "503"
    response_page_path    = "${var.offline_bucket_origin_path}/index.html"
  }

  custom_error_response {
    error_code            = "502"
    error_caching_min_ttl = "60"
    response_code         = "502"
    response_page_path    = "${var.offline_bucket_origin_path}/index.html"
  }

  enabled = true
  aliases = "${var.cloudfront_aliases}"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project_name}-${var.environment}-default-origin"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 5
    max_ttl     = 86400

    viewer_protocol_policy = "redirect-to-https"
  }

  cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project_name}-${var.environment}-offline"

    path_pattern = "${var.offline_bucket_origin_path}/*"

    forwarded_values = {
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

  cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project_name}-${var.environment}-default-origin"

    path_pattern = "/assets/*"

    forwarded_values = {
      query_string = false
      headers      = ["Host"]

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400

    viewer_protocol_policy = "redirect-to-https"
  }

  cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project_name}-${var.environment}-default-origin"

    path_pattern = "/api/*"

    forwarded_values = {
      query_string = true
      headers      = ["Host", "Authorization"]

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 900
    default_ttl = 3600
    max_ttl     = 86400

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${var.cloudfront_certificate_arn}"
    ssl_support_method  = "sni-only"
  }

  tags {
    Name        = "${var.project_name}-${var.environment}"
    Environment = "${var.environment}"
  }
}
