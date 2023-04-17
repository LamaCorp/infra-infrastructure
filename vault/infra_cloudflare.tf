resource "vault_generic_secret" "infra_cloudflare_root" {
  path         = "${vault_mount.infra.path}/cloudflare/root"
  disable_read = true
  data_json = jsonencode({
    api_key = "FIXME: get the global one from Cloudflare dashboard"
  })
}
