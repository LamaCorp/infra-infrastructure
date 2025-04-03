resource "random_password" "k8s-k3s-fsn-lama-tel_services-lemmy_admin" {
  count   = 1
  length  = 32
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-lemmy_admin" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-lemmy/admin"
  data_json = jsonencode({
    password = random_password.k8s-k3s-fsn-lama-tel_services-lemmy_admin[0].result
  })
}

resource "random_password" "k8s-k3s-fsn-lama-tel_services-lemmy_pictrs" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-lemmy_pictrs" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-lemmy/pictrs"
  data_json = jsonencode({
    api_key = random_password.k8s-k3s-fsn-lama-tel_services-lemmy_pictrs[0].result
  })
}
