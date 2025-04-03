resource "vault_mount" "k8s-global" {
  path = "k8s-global"
  type = "kv"
  options = {
    version = 2
  }
}

resource "vault_generic_secret" "k8s-global_core-cert-manager_cloudflare" {
  path         = "${vault_mount.k8s-global.path}/core-cert-manager/cloudflare"
  disable_read = true
  data_json = jsonencode({
    api_token = "FIXME: Create an API token with Zone Read, DNS Edit and access to all zones"
  })
}

resource "vault_generic_secret" "k8s-global_core-external-dns_cloudflare" {
  path         = "${vault_mount.k8s-global.path}/core-external-dns/cloudflare"
  disable_read = true
  data_json = jsonencode({
    api_token = "FIXME: Create an API token with Zone Read, DNS Edit and access to all zones"
  })
}

resource "vault_generic_secret" "k8s-global_core-observability_alertmanager_discord-webhooks" {
  path         = "${vault_mount.k8s-global.path}/core-observability/alertmanager/discord-webhooks"
  disable_read = true
  data_json = jsonencode({
    infra-alerts          = "FIXME: this should be a slack webhook pointing to the #infra-alerts channel."
    infra-critical-alerts = "FIXME: this should be a slack webhook pointing to the #infra-critical-alerts channel."
  })
}

resource "vault_generic_secret" "k8s-global_core-observability_loki-auth" {
  path = "${vault_mount.k8s-global.path}/core-observability/loki-auth"
  data_json = jsonencode({
    username = "infra"
    password = random_password.k8s-k3s-fsn-lama-tel_infra-observability_loki-auth-map["infra"].result
  })
}
