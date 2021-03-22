data "aws_route53_zone" "zone" {
  for_each = local.route53_zones
  name     = each.value
}

data "aws_iam_user" "deploy" {
  user_name = "deploy"
}

data "aws_iam_role" "deployments" {
  name = "deployments"
}
