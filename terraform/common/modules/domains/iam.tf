# This `terraform/common` code is run by privileged accounts only
# The IAM policies below grant specific permissions to the `deploy` user
# They are used when a GitHub Actions workflow uses `terraform apply`
# The `deploy` user does not need permission to create Route53 zone

# Route53 all zones

data "aws_iam_policy_document" "route53_all" {
  statement {
    actions   = ["route53:ListHostedZones"]
    resources = ["*"]
  }

  statement {
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }
}

resource "aws_iam_policy" "route53_all" {
  name   = "route53_all"
  policy = data.aws_iam_policy_document.route53_all.json
}

resource "aws_iam_role_policy_attachment" "route53_all" {
  role       = data.aws_iam_role.deployments.name
  policy_arn = aws_iam_policy.route53_all.arn
}

# Route53 specific hosted zones

data "aws_iam_policy_document" "route53_hosted_zones" {

  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:GetHostedZoneCount",
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
    ]
    resources = [
      for zone in local.route53_zones :
      "arn:aws:route53:::hostedzone/${aws_route53_zone.zones[zone].zone_id}"
    ]
  }
}

resource "aws_iam_policy" "route53_hosted_zones" {
  name   = "route53_hosted_zones"
  policy = data.aws_iam_policy_document.route53_hosted_zones.json
}


resource "aws_iam_role_policy_attachment" "route53_hosted_zones" {
  role       = data.aws_iam_role.deployments.name
  policy_arn = aws_iam_policy.route53_hosted_zones.arn
}
