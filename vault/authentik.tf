resource "vault_mount" "authentik" {
  path = "authentik"
  type = "kv-v2"
}

resource "random_password" "authentik_admin" {
  count   = 2
  length  = 64
  special = false
}
resource "vault_generic_secret" "authentik_admin" {
  path = "${vault_mount.authentik.path}/admin"
  data_json = jsonencode({
    password = random_password.authentik_admin[0].result
    token    = random_password.authentik_admin[1].result
  })
}

resource "random_password" "authentik_secret-key" {
  length  = 64
  special = false
}
resource "vault_generic_secret" "authentik_secret-key" {
  path = "${vault_mount.authentik.path}/secret-key"
  data_json = jsonencode({
    key = random_password.authentik_secret-key.result
  })
}
