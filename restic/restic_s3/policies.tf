data "aws_iam_policy_document" "backup_policy" {
  statement {
    sid = "backup_acl_lock_${var.bucket_name}"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/locks",
      "arn:aws:s3:::${var.bucket_name}/locks/*"
    ]
  }
  statement {
    sid = "backup_acl_${var.bucket_name}"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
}

data "aws_iam_policy_document" "prune_policy" {
  statement {
    sid = "prune_acl_${var.bucket_name}"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
}
