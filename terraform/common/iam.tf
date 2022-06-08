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
    actions   = ["ssm:GetParameter", "ssm:GetParametersByPath"]
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
      "acm:ListTagsForCertificate"
    ]
    resources = ["*"]
  }

  # Cloudfront
  statement {
    sid       = "ManageCloudfront"
    actions   = ["cloudfront:*"]
    resources = ["*"]
  }

  # IAM user/key/policy management for file attachment buckets
  statement {
    sid = "ManageAttachmentBucketUsers"
    actions = [
      "iam:GetUser",
      "iam:CreateUser",
      "iam:UpdateUser",
      "iam:DeleteUser",
      "iam:ListGroupsForUser",
      "iam:ListAccessKeys",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAttachedUserPolicies",
      "iam:AttachUserPolicy",
      "iam:DetachUserPolicy"
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/attachment_buckets_users/*"]
  }
  statement {
    sid = "ManageAttachmentBucketPolicies"
    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:CreatePolicyVersion"
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/attachment_buckets_policies/*"]
  }

  # S3 file attachment buckets
  statement {
    sid       = "ManageAttachmentBucketS3"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${data.aws_caller_identity.current.account_id}-${local.service_abbreviation}-attachments-*"]
  }

  # DB backups in S3
  statement {
    sid     = "ManageDatabaseBackupsS3Files"
    actions = ["s3:GetObject", "s3:GetObjectAcl", "s3:PutObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.db_backups.bucket}/full/*",
      "arn:aws:s3:::${aws_s3_bucket.db_backups.bucket}/sanitised/*"
    ]
  }

  statement {
    sid       = "ManageDatabaseBackupsS3Bucket"
    actions   = ["s3:GetBucketAcl", "s3:GetBucketLocation", "s3:ListBucket", "s3:PutBucketAcl"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.db_backups.bucket}"]
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
      "arn:aws:s3:::${aws_s3_bucket.db_backups.bucket}/full/*",
      "arn:aws:s3:::${data.aws_s3_bucket.terraform_state.bucket}/production/*"
    ]
  }
  statement {
    actions   = ["s3:ListBucket"]
    effect    = "Deny"
    resources = ["arn:aws:s3:::${aws_s3_bucket.db_backups.bucket}"]
    condition {
      test     = "StringEquals"
      variable = "s3:prefix"

      values = [
        "full/"
      ]
    }
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
