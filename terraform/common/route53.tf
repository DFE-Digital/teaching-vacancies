data aws_route53_zone zones {
  for_each = local.route53_zones
  name     = each.value
}
