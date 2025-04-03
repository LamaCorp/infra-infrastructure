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
