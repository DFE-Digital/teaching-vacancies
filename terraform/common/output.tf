output aws_access_key_id {
  value = aws_iam_access_key.deploy.id
}

output aws_secret_access_key {
  value = aws_iam_access_key.deploy.secret
}

output aws_access_key_id {
  value = aws_iam_access_key.bigquery.id
}

output aws_secret_access_key {
  value = aws_iam_access_key.bigquery.secret
}
