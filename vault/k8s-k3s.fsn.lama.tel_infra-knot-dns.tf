locals {
  k8s-k3s-fsn-lama-tel_infra-knot-dns_keys = toset([
    "happydomain",
    "k8s_external-dns",
    "ns1_xfr",
    "ns1_notify",
    "ns2_xfr",
    "ns2_notify",
  ])
}

resource "random_bytes" "k8s-k3s-fsn-lama-tel_infra-knot-dns_keys" {
  for_each = local.k8s-k3s-fsn-lama-tel_infra-knot-dns_keys

  length = 1024 / 8
}

resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_infra-knot-dns_keys" {
  for_each = local.k8s-k3s-fsn-lama-tel_infra-knot-dns_keys

  path = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/infra-knot-dns/keys/${each.key}"
  data_json = jsonencode({
    "${each.key}.conf" = <<-EOF
      key:
        - id: ${each.key}
          algorithm: hmac-sha512
          secret: "${random_bytes.k8s-k3s-fsn-lama-tel_infra-knot-dns_keys[each.key].base64}"
    EOF

    key = random_bytes.k8s-k3s-fsn-lama-tel_infra-knot-dns_keys[each.key].base64
  })
}
