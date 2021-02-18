resource "aws_acm_certificate" "cert" {
  provider                  = aws.aws_us_east_1
  domain_name               = var.primary_zone_name
  subject_alternative_names = local.subject_alternative_names
  validation_method         = "DNS"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert" {
  provider        = aws.aws_us_east_1
  certificate_arn = aws_acm_certificate.cert.arn
  # We use an explicit dependency and pass this directly from the
  # domain_validation_options instead of using the fqdn from
  # aws_route53_record.cert_validation because we may be skipping the creation
  # of some route53 records, and we need to provide all validation FQDNs, even
  # if we do not create them.
  validation_record_fqdns = aws_acm_certificate.cert.domain_validation_options[*].resource_record_name

  depends_on = [
    aws_route53_record.cert_validation
  ]
}

resource "aws_route53_record" "cert_validation" {
  for_each = local.route53_zones
  zone_id  = data.aws_route53_zone.zone[each.key].zone_id
  name     = local.validations[each.key].resource_record_name
  type     = local.validations[each.key].resource_record_type
  records  = [local.validations[each.key].resource_record_value]
  ttl      = 300
}
