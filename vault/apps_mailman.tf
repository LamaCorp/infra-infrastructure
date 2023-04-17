resource "random_password" "apps_mailman_secrets" {
  for_each = toset(["secret-key", "hyperkitty-api-key"])
  length   = 64
  special  = false
}

resource "vault_generic_secret" "apps_mailman_secrets" {
  path = "${vault_mount.apps.path}/mailman/secrets"
  data_json = jsonencode({
    for secret, value in random_password.apps_mailman_secrets :
    secret => value.result
  })
}
