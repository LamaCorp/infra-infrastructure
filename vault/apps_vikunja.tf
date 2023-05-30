resource "random_password" "apps_vikunja_secret-key" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "apps_vikunja_secret-key" {
  path = "${vault_mount.apps.path}/vikunja/secret-key"
  data_json = jsonencode({
    key = random_password.apps_vikunja_secret-key.result
  })
}
