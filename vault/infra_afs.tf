resource "vault_generic_secret" "infra_afs_keytab" {
  path         = "${vault_mount.infra.path}/afs/keytab"
  disable_read = true
  data_json = jsonencode({
    keytab = "FIXME: ktadd | base64"
  })
}
