data aws_caller_identity current {}

resource aws_s3_bucket cloudfront-logs {
  bucket = "${data.aws_caller_identity.current.account_id}-tv-cloudfront-logs-spike"
}
