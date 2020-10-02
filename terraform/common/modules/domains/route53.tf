resource aws_route53_zone zones {
  for_each      = local.route53_zones
  name          = each.value
  comment       = "DNS Zone for Teaching Vacancies"
  force_destroy = false
}

resource aws_route53_record CAA {
  for_each = local.route53_zones
  zone_id  = aws_route53_zone.zones[each.value].zone_id
  name     = each.value
  records  = ["0 issue \"amazon.com\""]
  ttl      = "300"
  type     = "CAA"
}

resource aws_route53_record SPF {
  for_each = local.route53_zones
  zone_id  = aws_route53_zone.zones[each.value].zone_id
  name     = each.value
  records  = ["v=spf1 -all"]
  ttl      = "300"
  type     = "TXT"
}

resource aws_route53_record DMARC {
  for_each = local.route53_zones
  zone_id  = aws_route53_zone.zones[each.value].zone_id
  name     = "_dmarc.${each.value}"
  records  = ["v=DMARC1; p=reject; sp=reject; rua=mailto:dmarc-rua@dmarc.service.gov.uk; ruf=mailto:dmarc-ruf@dmarc.service.gov.uk"]
  ttl      = "300"
  type     = "TXT"
}

resource aws_route53_record bing {
  zone_id = aws_route53_zone.zones[var.secondary_zone_name].zone_id
  name    = "${local.secondary_zone_bing_validation_record_name}.${var.secondary_zone_name}"
  records = ["verify.bing.com."]
  ttl     = "300"
  type    = "CNAME"
}
