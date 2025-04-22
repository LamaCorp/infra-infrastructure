locals {
  paperless_instances = toset([
    "risson",
  ])
}

resource "random_password" "k8s-k3s-fsn-as212024-net_services-paperless-ngx_secret-key" {
  for_each = local.paperless_instances
  length   = 64
  special  = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-paperless-ngx_secret-key" {
  for_each = local.paperless_instances
  path     = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-paperless-ngx-${each.key}/secret-key"
  data_json = jsonencode({
    secret_key = random_password.k8s-k3s-fsn-as212024-net_services-paperless-ngx_secret-key[each.key].result
  })
}
