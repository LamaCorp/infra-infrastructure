resource "vault_generic_secret" "apps_your_spotify_spotify-oauth" {
  path         = "${vault_mount.apps.path}/your_spotify/spotify-oauth"
  disable_read = true
  data_json = jsonencode({
    client_id     = "FIXME"
    client_secret = "FIXME"
  })
}
