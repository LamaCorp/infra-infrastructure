resource "vault_mount" "postgresql" {
  path = "postgresql"
  type = "kv-v2"
}

locals {
  postgresql_users = toset([
    "atuin",
    "authentik",
    "gatus_authentik",
    "gatus_devoups",
    "gatus_phowork",
    "gatus_prologin",
    "hedgedoc",
    "lidarr",
    "mailman",
    "matrix_dimension",
    "matrix_ma1sd",
    "matrix_maubot",
    "matrix_mautrix_facebook",
    "matrix_mautrix_slack",
    "matrix_synapse",
    "mattermost",
    "netbox",
    "nextcloud",
    "paperless_risson",
    "prowlarr",
    "radarr",
    "readarr",
    "upsilon",
    "vaultwarden",
    "vikunja",
  ])
}

resource "random_password" "postgresql_users" {
  for_each = local.postgresql_users
  length   = 64
  special  = false
}

resource "vault_generic_secret" "postgresql_users" {
  for_each = local.postgresql_users
  path     = "${vault_mount.postgresql.path}/users/${each.key}"
  data_json = jsonencode({
    password = random_password.postgresql_users[each.key].result
  })
}
