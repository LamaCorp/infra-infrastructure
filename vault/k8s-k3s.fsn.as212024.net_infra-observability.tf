locals {
  k8s-k3s-fsn-as212024-net_infra-observability_loki-auth-map-users = toset(["infra", "pie"])
}

resource "random_password" "k8s-k3s-fsn-as212024-net_infra-observability_loki-auth-map" {
  for_each = local.k8s-k3s-fsn-as212024-net_infra-observability_loki-auth-map-users
  length   = 64
  special  = false
}
resource "random_password" "k8s-k3s-fsn-as212024-net_infra-observability_loki-auth-map-salt" {
  for_each = local.k8s-k3s-fsn-as212024-net_infra-observability_loki-auth-map-users
  length   = 8
  special  = false
}
resource "htpasswd_password" "k8s-k3s-fsn-as212024-net_infra-observability_loki-auth-map" {
  for_each = random_password.k8s-k3s-fsn-as212024-net_infra-observability_loki-auth-map
  password = each.value.result
  salt     = random_password.k8s-k3s-fsn-as212024-net_infra-observability_loki-auth-map-salt[each.key].result
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_infra-observability_loki-auth-map" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/infra-observability/loki-auth-map"
  data_json = jsonencode({
    ".htpasswd" = <<-EOF
      %{for username in local.k8s-k3s-fsn-as212024-net_infra-observability_loki-auth-map-users}
      ${username}=${htpasswd_password.k8s-k3s-fsn-as212024-net_infra-observability_loki-auth-map[username].bcrypt}
      %{endfor}
    EOF
  })
}
