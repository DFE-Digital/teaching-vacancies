# This `terraform/common` code is run by privileged accounts only
# The IAM policies below grant specific permissions to the `deploy` user
# They are used when a GitHub Actions workflow uses `terraform apply`
# The `deploy` user does not need permission to create an ACM certificate

resource aws_iam_user deploy {
  name = "deploy"
  path = "/tvs/"
}

resource aws_iam_access_key deploy {
  user = aws_iam_user.deploy.name
}

resource aws_iam_user bigquery {
  name = "bigquery"
  path = "/tvs/"
}

resource aws_iam_access_key bigquery {
  user = aws_iam_user.bigquery.name
}

# Terraform state

data aws_iam_policy_document edit_terraform_state {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}/*"]
  }
  statement {
    actions   = ["s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}/review:/*"]
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

data aws_iam_policy_document read_ssm_parameters {
  statement {
    actions   = ["ssm:GetParameter", "ssm:GetParametersByPath"]
    resources = ["*"]
  }
}

resource aws_iam_policy read_ssm_parameters {
  name   = "read-ssm-parameter"
  policy = data.aws_iam_policy_document.read_ssm_parameters.json
}

resource aws_iam_user_policy_attachment read_ssm_parameters {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.read_ssm_parameters.arn
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

# ACM

data aws_iam_policy_document acm {
  statement {
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:ListTagsForCertificate"
    ]
    resources = ["*"]
  }
}

resource aws_iam_policy acm {
  name   = "acm"
  policy = data.aws_iam_policy_document.acm.json
}

resource aws_iam_user_policy_attachment acm {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.acm.arn
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

# Allow BigQuery to collect Cloudfront logs from S3 bucket

data aws_iam_policy_document cloudfront_logs_bigquery_access {
  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudfront_logs.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.cloudfront_logs.bucket}/*"
    ]
  }
}

resource aws_iam_policy cloudfront_logs_bigquery_access {
  name   = "cloudfront_logs_bigquery_access"
  policy = data.aws_iam_policy_document.cloudfront_logs_bigquery_access.json
}

resource aws_iam_user_policy_attachment cloudfront_logs_bigquery_access {
  user       = aws_iam_user.bigquery.name
  policy_arn = aws_iam_policy.cloudfront_logs_bigquery_access.arn
}
