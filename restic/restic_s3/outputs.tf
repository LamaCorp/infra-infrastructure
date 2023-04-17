output "bucket_name" {
  value = minio_s3_bucket.this.bucket
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
