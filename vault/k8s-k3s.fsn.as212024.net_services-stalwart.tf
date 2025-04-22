resource "random_password" "k8s-k3s-fsn-as212024-net_services-stalwart_secrets" {
  count   = 2
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-stalwart_secrets" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-stalwart/secrets"
  data_json = jsonencode({
    fallback-admin_secret = random_password.k8s-k3s-fsn-as212024-net_services-stalwart_secrets[0].result
    master_secret         = random_password.k8s-k3s-fsn-as212024-net_services-stalwart_secrets[1].result
  })
}
