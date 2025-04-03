resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-eos_sss-keytab" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-eos/sss-keytab"
  disable_read = true
  data_json = jsonencode({
    "eos.keytab" = "FIXME: docker run -it --rm -v /tmp/eos:/tmp/eos --entrypoint='' gitlab-registry.cern.ch/dss/eos/eos-ci:5.2.4 xrdsssadmin -k eos+ -u daemon -g daemon add /tmp/eos/keytab && cat /tmp/eos/keytab"
  })
}

resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-eos_krb5-keytab" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-eos/krb5-keytab"
  disable_read = true
  data_json = jsonencode({
    keytab = "FIXME"
  })
}
