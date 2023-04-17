resource "random_password" "apps_nextcloud_admin" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "apps_nextcloud_admin" {
  path = "${vault_mount.apps.path}/nextcloud/admin"
  data_json = jsonencode({
    password = random_password.apps_nextcloud_admin.result
  })
}
