resource "random_password" "apps_netbox_admin" {
  count   = 2
  length  = 64
  special = false
}

resource "vault_generic_secret" "apps_netbox_admin" {
  path = "${vault_mount.apps.path}/netbox/admin"
  data_json = jsonencode({
    password  = random_password.apps_netbox_admin[0].result
    api_token = random_password.apps_netbox_admin[1].result
  })
}
