resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-hanabi_secrets" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-hanabi/secrets"
  disable_read = true
  data_json = jsonencode({
    DISCORD_BOT_TOKEN = "FIXME: get this from hane"
  })
}
