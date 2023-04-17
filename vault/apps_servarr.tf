resource "random_password" "apps_servarr_api-key" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "apps_servarr_api-key" {
  path = "${vault_mount.apps.path}/servarr/api-key"
  data_json = jsonencode({
    key = random_password.apps_servarr_api-key.result
  })
}
