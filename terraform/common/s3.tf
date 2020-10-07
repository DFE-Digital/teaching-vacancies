data aws_caller_identity current {}

resource aws_s3_bucket db_backups {
  bucket = "${data.aws_caller_identity.current.account_id}-tv-db-backups"
}

resource aws_s3_bucket cloudfront_logs {
  bucket = "${data.aws_caller_identity.current.account_id}-tv-cloudfront-logs"

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
