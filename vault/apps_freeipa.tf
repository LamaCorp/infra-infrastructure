resource "random_password" "apps_freeipa_admin" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "apps_freeipa_admin" {
  path = "${vault_mount.apps.path}/freeipa/admin"
  data_json = jsonencode({
    password = random_password.apps_freeipa_admin.result
  })
}
