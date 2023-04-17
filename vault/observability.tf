resource "vault_mount" "observability" {
  path = "observability"
  type = "kv-v2"
}

resource "vault_generic_secret" "observability_discord-webhooks" {
  path         = "${vault_mount.observability.path}/discord-webhooks"
  disable_read = true
  data_json = jsonencode({
    infra-alerts          = "FIXME"
    infra-critical-alerts = "FIXME"
  })
}

resource "random_password" "observability_grafana_admin" {
  length  = 64
  special = false
}
resource "vault_generic_secret" "observability_grafana_admin" {
  path = "${vault_mount.observability.path}/grafana/admin"
  data_json = jsonencode({
    username = "admin"
    password = random_password.observability_grafana_admin.result
  })
}

resource "vault_generic_secret" "observability_grafana_cloudflare-token" {
  path         = "${vault_mount.observability.path}/grafana/cloudflare-token"
  disable_read = true
  data_json = jsonencode({
    token = "FIXME"
  })
}

resource "random_password" "observability_loki_basic-auth" {
  for_each = toset(["infra", "pie"])
  length   = 64
  special  = false
}
resource "random_password" "observability_loki_basic-auth_salt" {
  for_each = toset(["infra", "pie"])
  length   = 8
  special  = false
}
resource "htpasswd_password" "observability_loki_basic-auth" {
  for_each = random_password.observability_loki_basic-auth
  password = each.value.result
  salt     = random_password.observability_loki_basic-auth_salt[each.key].result
}
resource "vault_generic_secret" "observability_loki_basic-auth" {
  for_each = random_password.observability_loki_basic-auth
  path     = "${vault_mount.observability.path}/loki/basic-auth/${each.key}"
  data_json = jsonencode({
    username = each.key
    password = each.value.result
    htpasswd = htpasswd_password.observability_loki_basic-auth[each.key].apr1
  })
}
