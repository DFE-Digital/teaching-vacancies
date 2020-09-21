resource aws_iam_user deploy {
  name = "deploy"
  path = "/tvs/"
}

resource aws_iam_access_key deploy {
  user = aws_iam_user.deploy.name
}

# Terraform state

data aws_iam_policy_document edit_terraform_state {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}/*"]
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}"]
  }
}

resource aws_iam_policy edit_terraform_state {
  name   = "edit-terraform-state"
  policy = data.aws_iam_policy_document.edit_terraform_state.json
}

resource aws_iam_user_policy_attachment edit_terraform_state {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.edit_terraform_state.arn
}

# SSM

data aws_iam_policy_document read_ssm_parameter {
  statement {
    actions   = ["ssm:GetParameter"]
    resources = ["*"]
  }
}

resource aws_iam_policy read_ssm_parameter {
  name   = "read-ssm-parameter"
  policy = data.aws_iam_policy_document.read_ssm_parameter.json
}

resource aws_iam_user_policy_attachment read_ssm_parameter {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.read_ssm_parameter.arn
}

# Cloudwatch

data aws_iam_policy_document cloudwatch {
  statement {
    actions   = ["iam:*"]
    resources = ["arn:aws:iam::*:role/*-slack-lambda-role"]
  }
  statement {
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    actions   = ["sns:*"]
    resources = ["*"]
  }
  statement {
    actions   = ["logs:*"]
    resources = ["*"]
  }
  statement {
    actions   = ["lambda:*"]
    resources = ["arn:aws:lambda:*:*:function:*"]
  }
}

resource aws_iam_policy cloudwatch {
  name   = "cloudwatch"
  policy = data.aws_iam_policy_document.cloudwatch.json
}

resource aws_iam_user_policy_attachment cloudwatch {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.cloudwatch.arn
}

# Cloudfront

data aws_iam_policy_document cloudfront {
  statement {
    actions   = ["cloudfront:*"]
    resources = ["*"]
  }

}

resource aws_iam_policy cloudfront {
  name   = "cloudfront"
  policy = data.aws_iam_policy_document.cloudfront.json
}

resource aws_iam_user_policy_attachment cloudfront {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.cloudfront.arn
}

# Upload DB backups to S3

data aws_iam_policy_document upload_db_backups_to_s3 {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.db_backups.bucket}/*"]
  }
}

resource aws_iam_policy upload_db_backups_to_s3 {
  name   = "upload_db_backups_to_s3"
  policy = data.aws_iam_policy_document.upload_db_backups_to_s3.json
}

resource aws_iam_user_policy_attachment upload_db_backups_to_s3 {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.upload_db_backups_to_s3.arn
}

# Cloudfront logs to S3

data aws_iam_policy_document cloudfront_logs_to_s3 {
  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket",
      "s3:PutBucketAcl",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudfront_logs.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.cloudfront_logs.bucket}/*"
    ]
  }
}

resource aws_iam_policy cloudfront_logs_to_s3 {
  name   = "cloudfront_logs_to_s3"
  policy = data.aws_iam_policy_document.cloudfront_logs_to_s3.json
}

resource aws_iam_user_policy_attachment cloudfront_logs_to_s3 {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.cloudfront_logs_to_s3.arn
}

# Route53 all zones

data aws_iam_policy_document route53_all {
  statement {
    actions   = ["route53:ListHostedZones"]
    resources = ["*"]
  }

  statement {
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }
}

resource aws_iam_policy route53_all {
  name   = "route53_all"
  policy = data.aws_iam_policy_document.route53_all.json
}

resource aws_iam_user_policy_attachment route53_all {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.route53_all.arn
}

# Route53 specific hosted zones

data aws_iam_policy_document route53_hosted_zones {

  statement {
    actions = [
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:GetHostedZoneCount",
      "route53:ListHostedZonesByName"
    ]
    resources = [
      for zone in var.route53_zones :
      "arn:aws:route53:::hostedzone/${data.aws_route53_zone.zones[zone].zone_id}"
    ]
  }
}

resource aws_iam_policy route53_hosted_zones {
  name   = "route53_hosted_zones"
  policy = data.aws_iam_policy_document.route53_hosted_zones.json
}

resource aws_iam_user_policy_attachment route53_hosted_zones {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.route53_hosted_zones.arn
}
