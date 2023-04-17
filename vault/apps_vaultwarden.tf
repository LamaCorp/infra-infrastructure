resource "random_password" "apps_vaultwarden_admin-token" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "apps_vaultwarden_admin-token" {
  path = "${vault_mount.apps.path}/vaultwarden/admin-token"
  data_json = jsonencode({
    token = random_password.apps_vaultwarden_admin-token.result
  })
}
