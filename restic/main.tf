resource "random_string" "bucket_name_suffix" {
  for_each = local.repositories_computed
  length   = 63 - length(each.key) - 1
  lower    = true
  numeric  = true
  upper    = false
  special  = false
}

module "s3_resources" {
  source = "./restic_s3"

  for_each = local.repositories_computed

  bucket_name     = replace(replace("${each.key}_${random_string.bucket_name_suffix[each.key].result}", "_", "-"), ".", "-")
  backup_username = "${each.key}_backup"
  prune_username  = "${each.key}_prune"
}

resource "random_password" "restic_password" {
  for_each = local.repositories_computed
  length   = 64
  special  = false
}

resource "vault_generic_secret" "credentials" {
  for_each = local.repositories_computed
  path     = "restic/repositories/${each.value.machine}/${each.value.repository}"
  data_json = jsonencode({
    repo_password     = random_password.restic_password[each.key].result
    bucket_name       = module.s3_resources[each.key].bucket_name
    backup_access_key = module.s3_resources[each.key].backup_user_key["access_key"]
    backup_secret_key = module.s3_resources[each.key].backup_user_key["secret_key"]
    prune_access_key  = module.s3_resources[each.key].prune_user_key["access_key"]
    prune_secret_key  = module.s3_resources[each.key].prune_user_key["secret_key"]
  })
}
