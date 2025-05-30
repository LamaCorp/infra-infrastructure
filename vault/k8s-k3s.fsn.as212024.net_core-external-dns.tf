resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_core-external-dns_tsig" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/core-external-dns/tsig"
  data_json = jsonencode({
    secret = random_bytes.k8s-k3s-fsn-as212024-net_infra-knot-dns_keys["k8s_k3s-fsn-as212024-net_core-external-dns"].base64
  })
}
