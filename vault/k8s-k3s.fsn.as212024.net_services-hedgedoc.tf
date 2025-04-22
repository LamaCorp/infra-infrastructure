resource "random_password" "k8s-k3s-fsn-as212024-net_services-hedgedoc_secrets" {
  count   = 1
  length  = 64
  special = false
}

resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-hedgedoc_secrets" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-hedgedoc/secrets"
  data_json = jsonencode({
    CMD_SESSION_SECRET = random_password.k8s-k3s-fsn-as212024-net_services-hedgedoc_secrets[0].result
  })
}
