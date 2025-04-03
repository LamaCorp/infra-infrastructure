resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_kube-system_coredns_dnssec" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/kube-system/coredns/dnssec"
  disable_read = true
  data_json = jsonencode({
    key     = "FIXME: dnssec-keygen -a ECDSAP256SHA256 k3s.fsn.lama.tel"
    private = "FIXME: dnssec-keygen -a ECDSAP256SHA256 k3s.fsn.lama.tel"
  })
}
