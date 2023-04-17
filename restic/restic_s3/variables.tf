# Bucket
variable "bucket_name" {
  type = string
}


# Users

## Backup
variable "backup_username" {
  type = string
}

variable "backup_policy_name" {
  type    = string
  default = "backup_user_policy"
}

## Prune
variable "prune_username" {
  type = string
}

variable "prune_policy_name" {
  type    = string
  default = "prune_user_policy"
}
