resource "random_password" "apps_jellyfin_admin" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "apps_jellyfin_admin" {
  path = "${vault_mount.apps.path}/jellyfin/admin"
  data_json = jsonencode({
    password = random_password.apps_jellyfin_admin.result
  })
}
