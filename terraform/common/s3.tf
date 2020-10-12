data aws_caller_identity current {}
data aws_canonical_user_id current {}

resource aws_s3_bucket db_backups {
  bucket = "${data.aws_caller_identity.current.account_id}-tv-db-backups"

  lifecycle_rule {
    id      = "backups"
    enabled = true

    expiration {
      days = 7
    }
  }
}

resource aws_s3_bucket cloudfront_logs {
  bucket = "${data.aws_caller_identity.current.account_id}-tv-cloudfront-logs"

  # Specifically setting the ACL grant from awslogsdelivery
  # By explicitly setting any grant, we must declare ALL grants (i.e. also the bucket owner)
  grant {
    id          = local.aws_canonical_user_id_awslogsdelivery
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  grant {
    id          = data.aws_canonical_user_id.current.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  lifecycle_rule {
    id      = "staging"
    enabled = true

    prefix = "staging/"

    expiration {
      days = 3
    }
  }

  lifecycle_rule {
    id      = "production"
    enabled = true

    prefix = "production/"

    expiration {
      days = 35
    }
  }

}
