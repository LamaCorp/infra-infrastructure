resource "vault_mount" "restic" {
  path = "restic"
  type = "kv-v2"
}

resource "vault_generic_secret" "restic_wasabi-credentials" {
  # Generate on https://secure.backblaze.com/app_keys.htm
  path         = "${vault_mount.restic.path}/wasabi-credentials"
  disable_read = true
  data_json = jsonencode({
    access_key = "FIXME"
    secret_key = "FIXME"
  })
}
