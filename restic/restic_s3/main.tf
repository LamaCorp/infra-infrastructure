# Create bucket
# This will be changed to use the aws provider once a compatibily bug between
# aws provider and Wasabi is resolved
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = false
}
resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Backup user
resource "aws_iam_user" "backup" {
  name          = var.backup_username
  force_destroy = true
}
resource "aws_iam_access_key" "backup" {
  user = aws_iam_user.backup.name
}
resource "aws_iam_user_policy" "backup" {
  name   = var.backup_policy_name
  user   = aws_iam_user.backup.name
  policy = data.aws_iam_policy_document.backup_policy.json
}

# Prune user
resource "aws_iam_user" "prune" {
  name          = var.prune_username
  force_destroy = true
}
resource "aws_iam_access_key" "prune" {
  user = aws_iam_user.prune.name
}
resource "aws_iam_user_policy" "prune" {
  name   = var.prune_policy_name
  user   = aws_iam_user.prune.name
  policy = data.aws_iam_policy_document.prune_policy.json
}
