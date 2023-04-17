resource "vault_generic_secret" "apps_upsilon_keytab" {
  path         = "${vault_mount.apps.path}/upsilon/keytab"
  disable_read = true
  data_json = jsonencode({
    keytab = "FIXME: ktadd | base64"
  })
}

resource "random_password" "apps_upsilon_secret-key" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "apps_upsilon_secret-key" {
  path = "${vault_mount.apps.path}/upsilon/secret-key"
  data_json = jsonencode({
    key = random_password.apps_upsilon_secret-key.result
  })
}

resource "tls_private_key" "apps_upsilon_oidc-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "vault_generic_secret" "apps_upsilon_oidc-private-key" {
  path = "${vault_mount.apps.path}/upsilon/oidc-private-key"
  data_json = jsonencode({
    private_key = tls_private_key.apps_upsilon_oidc-private-key.private_key_pem
    public_key  = tls_private_key.apps_upsilon_oidc-private-key.public_key_pem
  })
}

resource "random_password" "apps_upsilon_oauth-app-secret" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "apps_upsilon_oauth-app-secret" {
  path = "${vault_mount.apps.path}/upsilon/oauth-app-secret"
  data_json = jsonencode({
    client_secret = random_password.apps_upsilon_oauth-app-secret.result
  })
}
