resource "random_password" "apps_hedgedoc_secret-key" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "apps_hedgedoc_secret-key" {
  path = "${vault_mount.apps.path}/hedgedoc/secret-key"
  data_json = jsonencode({
    key = random_password.apps_hedgedoc_secret-key.result
  })
}
