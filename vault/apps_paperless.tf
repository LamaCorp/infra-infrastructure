locals {
  paperless_instances = toset([
    "risson",
  ])
}

resource "random_password" "apps_paperless_secret-key" {
  for_each = local.paperless_instances

  length  = 64
  special = false
}

resource "vault_generic_secret" "apps_paperless_secret-key" {
  for_each = local.paperless_instances

  path = "${vault_mount.apps.path}/paperless_${each.key}/secret-key"
  data_json = jsonencode({
    key = random_password.apps_paperless_secret-key[each.key].result
  })
}

resource "random_password" "apps_paperless_admin" {
  for_each = local.paperless_instances

  length  = 64
  special = false
}

resource "vault_generic_secret" "apps_paperless_admin" {
  for_each = local.paperless_instances

  path = "${vault_mount.apps.path}/paperless_${each.key}/admin"
  data_json = jsonencode({
    username = each.key
    password = random_password.apps_paperless_admin[each.key].result
  })
}
