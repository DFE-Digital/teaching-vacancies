resource aws_route53_zone zones {
  for_each      = local.route53_zones
  name          = each.value
  comment       = "DNS Zone for Teaching Vacancies"
  force_destroy = false
}

resource aws_route53_record route53_records {
  for_each = var.route53_records
  zone_id  = aws_route53_zone.zones[each.value.zone_name].zone_id
  name     = each.value.record_name
  records  = [each.value.record_value]
  ttl      = each.value.record_ttl
  type     = each.value.record_type
}
