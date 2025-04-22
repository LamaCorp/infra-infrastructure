resource "random_password" "k8s-k3s-fsn-as212024-net_services-nextcloud_admin" {
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-nextcloud_admin" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-nextcloud/admin"
  data_json = jsonencode({
    username = "admin"
    password = random_password.k8s-k3s-fsn-as212024-net_services-nextcloud_admin.result
  })
}
