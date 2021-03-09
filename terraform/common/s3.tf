data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "db_backups" {
  bucket = "${data.aws_caller_identity.current.account_id}-tv-db-backups"

  lifecycle_rule {
    id      = "full"
    prefix  = "full"
    enabled = true

    expiration {
      days = 7
    }
  }
  lifecycle_rule {
    id      = "sanitised"
    prefix  = "sanitised"
    enabled = true

    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket_public_access_block" "db_backups" {
  bucket = aws_s3_bucket.db_backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "offline_site" {
  bucket = "${data.aws_caller_identity.current.account_id}-offline-site"
}
