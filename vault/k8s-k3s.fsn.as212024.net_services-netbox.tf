resource "random_password" "k8s-k3s-fsn-as212024-net_services-netbox_secret-key" {
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-netbox_secret-key" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-netbox/secret-key"
  data_json = jsonencode({
    secret_key = random_password.k8s-k3s-fsn-as212024-net_services-netbox_secret-key.result
  })
}
