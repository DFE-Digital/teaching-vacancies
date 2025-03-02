resource "aws_s3_bucket" "db_backups" {
  bucket = "${data.aws_caller_identity.current.account_id}-tv-db-backups"
}

resource "aws_s3_bucket_lifecycle_configuration" "db_backups" {
  bucket = aws_s3_bucket.db_backups.id

  rule {
    id = "full"
    filter {
      prefix = "full/"
    }
    expiration {
      days = 7
    }
    status = "Enabled"
  }
  rule {
    id = "sanitised"
    filter {
      prefix = "sanitised/"
    }
    expiration {
      days = 7
    }
    status = "Enabled"
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

resource "aws_s3_bucket_public_access_block" "offline_site" {
  bucket = aws_s3_bucket.offline_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "offline_site" {
  bucket = aws_s3_bucket.offline_site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "OfflineSitePublicReadGetObject"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.offline_site.arn}/teaching-vacancies-offline/*",
        ]
      },
    ]
  })
}
