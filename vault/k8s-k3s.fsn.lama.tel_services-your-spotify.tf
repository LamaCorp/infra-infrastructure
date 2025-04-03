resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-your-spotify_secrets" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-your-spotify/secrets"
  disable_read = true
  data_json = jsonencode({
    SPOTIFY_PUBLIC = "FIXME"
    SPOTIFY_SECRET = "FIXME"
  })
}
