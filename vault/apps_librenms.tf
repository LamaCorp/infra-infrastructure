resource "random_password" "apps_librenms_admin" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "apps_librenms_admin" {
  path = "${vault_mount.apps.path}/librenms/admin"
  data_json = jsonencode({
    username = "admin"
    password = random_password.apps_librenms_admin.result
  })
}
