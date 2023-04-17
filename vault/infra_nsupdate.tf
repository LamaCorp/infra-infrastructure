resource "vault_generic_secret" "infra_nsupdate_credentials" {
  for_each = toset(["bar"])

  path         = "${vault_mount.infra.path}/nsupdate/credentials/${each.key}"
  disable_read = true
  data_json = jsonencode({
    username = "FIXME"
    password = "FIXME"
  })
}
