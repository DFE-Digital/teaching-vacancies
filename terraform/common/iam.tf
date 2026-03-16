# This `terraform/common` code is run by privileged accounts only
# The IAM policies below grant specific permissions to the `Deployments` role
# They are used when a GitHub Actions workflow uses `terraform apply`
# The `Deployments` role does not need permission to create an ACM certificate

resource "aws_iam_user" "deploy" {
  name = "deploy"
  path = "/${local.service_name}/"
}

resource "aws_iam_access_key" "deploy" {
  user = aws_iam_user.deploy.name
}

data "aws_iam_policy_document" "deployments_role_policy" {
  # Terraform state
  statement {
    sid     = "ReadWriteTerraformState"
    actions = ["s3:GetObject", "s3:PutObject"]
    resources = [
      "arn:aws:s3:::${data.aws_s3_bucket.terraform_state.bucket}/*"
    ]
  }
  statement {
    sid     = "DeleteTerraformState"
    actions = ["s3:DeleteObject", "s3:DeleteObjectVersion"]
    resources = [
      "arn:aws:s3:::${data.aws_s3_bucket.terraform_state.bucket}/review/*"
    ]
  }
  statement {
    sid     = "ListTerraformStateVersions"
    actions = ["s3:ListBucketVersions"]
    resources = [
      "arn:aws:s3:::${data.aws_s3_bucket.terraform_state.bucket}"
    ]
  }
  statement {
    sid     = "ListTerraformState"
    actions = ["s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${data.aws_s3_bucket.terraform_state.bucket}"
    ]
  }

  # SSM
  statement {
    sid       = "ReadSSMParameters"
    actions   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
    resources = ["*"]
  }

  # CloudWatch
  statement {
    sid       = "ManageCloudwatchIAMSlackLambdaRole"
    actions   = ["iam:*"]
    resources = ["arn:aws:iam::*:role/*-slack-lambda-role"]
  }
  statement {
    sid       = "ManageCloudwatchKMS"
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ManageCloudwatchSNS"
    actions   = ["sns:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ManageCloudwatchLogs"
    actions   = ["logs:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ManageCloudwatchLambda"
    actions   = ["lambda:*"]
    resources = ["arn:aws:lambda:*:*:function:*"]
  }

  # ACM
  statement {
    sid = "ReadACMCertificates"
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:ListTagsForCertificate",
      "acm:GetCertificate"
    ]
    resources = ["*"]
  }

  # Cloudfront
  statement {
    sid       = "ManageCloudfront"
    actions   = ["cloudfront:*"]
    resources = ["*"]
  }

  # Offline site in S3
  statement {
    sid       = "ManageOfflineSiteS3Files"
    actions   = ["s3:GetObject", "s3:GetObjectAcl", "s3:DeleteObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.offline_site.bucket}/teaching-vacancies-offline/*"]
  }

  statement {
    sid       = "ManageOfflineSiteS3Bucket"
    actions   = ["s3:GetBucketAcl", "s3:GetBucketLocation", "s3:ListBucket", "s3:PutBucketAcl"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.offline_site.bucket}"]
  }
}

resource "aws_iam_policy" "deployments_role_policy" {
  name   = "deployments_role_policy"
  policy = data.aws_iam_policy_document.deployments_role_policy.json
}

data "aws_iam_policy_document" "deny_sensitive_data_in_s3" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    effect = "Deny"
    resources = [
      "arn:aws:s3:::${data.aws_s3_bucket.terraform_state.bucket}/production/*"
    ]
  }
}

resource "aws_iam_policy" "deny_sensitive_data_in_s3" {
  name   = "deny_sensitive_data_in_s3"
  policy = data.aws_iam_policy_document.deny_sensitive_data_in_s3.json
}

resource "aws_iam_role_policy_attachment" "deny_sensitive_data_in_s3" {
  role       = aws_iam_role.readonly.name
  policy_arn = aws_iam_policy.deny_sensitive_data_in_s3.arn
}
