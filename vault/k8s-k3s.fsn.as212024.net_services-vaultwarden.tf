resource "random_password" "k8s-k3s-fsn-as212024-net_services-vaultwarden_secrets" {
  count   = 1
  length  = 64
  special = false
}

resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-vaultwarden_secrets" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-vaultwarden/secrets"
  data_json = jsonencode({
    ADMIN_TOKEN = random_password.k8s-k3s-fsn-as212024-net_services-vaultwarden_secrets[0].result
  })
}

resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-vaultwarden_push-secrets" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-vaultwarden/push-secrets"
  disable_read = true
  data_json = jsonencode({
    PUSH_INSTALLATION_ID  = "FIXME"
    PUSH_INSTALLATION_KEY = "FIXME"
  })
}
