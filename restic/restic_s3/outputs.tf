output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "backup_user_key" {
  value = {
    "access_key" = aws_iam_access_key.backup.id
    "secret_key" = aws_iam_access_key.backup.secret
  }
  sensitive = true
}

output "prune_user_key" {
  value = {
    "access_key" = aws_iam_access_key.prune.id
    "secret_key" = aws_iam_access_key.prune.secret
  }
  sensitive = true
}
