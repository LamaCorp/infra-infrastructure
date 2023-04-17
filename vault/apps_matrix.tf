resource "random_password" "apps_matrix_generic-secret-key" {
  length  = 64
  special = false
}
resource "vault_generic_secret" "apps_matrix_generic-secret-key" {
  path = "${vault_mount.apps.path}/matrix/generic-secret-key"
  data_json = jsonencode({
    key = random_password.apps_matrix_generic-secret-key.result
  })
}

resource "random_password" "apps_matrix_shared-secret-auth" {
  length  = 64
  special = false
}
resource "vault_generic_secret" "apps_matrix_shared-secret-auth" {
  path = "${vault_mount.apps.path}/matrix/shared-secret-auth"
  data_json = jsonencode({
    shared_secret = random_password.apps_matrix_shared-secret-auth.result
  })
}

resource "random_password" "apps_matrix_maubot-admin" {
  length  = 64
  special = false
}
resource "vault_generic_secret" "apps_matrix_maubot-admin" {
  path = "${vault_mount.apps.path}/matrix/maubot-admin"
  data_json = jsonencode({
    password = random_password.apps_matrix_maubot-admin.result
  })
}

resource "vault_generic_secret" "apps_matrix_access-token" {
  path         = "${vault_mount.apps.path}/matrix/access-token"
  disable_read = true
  data_json = jsonencode({
    token = "FIXME"
  })
}
