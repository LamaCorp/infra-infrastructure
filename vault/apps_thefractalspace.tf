resource "vault_generic_secret" "apps_thefractalspace_twitter" {
  path         = "${vault_mount.apps.path}/thefractalspace/twitter"
  disable_read = true
  data_json = jsonencode({
    access_key      = "FIXME"
    access_secret   = "FIXME"
    consumer_key    = "FIXME"
    consumer_secret = "FIXME"
  })
}
