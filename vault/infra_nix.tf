resource "vault_generic_secret" "infra_nix_cache-signing-key" {
  path         = "${vault_mount.infra.path}/nix/cache-signing-key"
  disable_read = true
  data_json = jsonencode({
    public_key  = "FIXME: nix-store --generate-binary-cache-key cache.nix.lama-corp.space priv.key pub.key"
    private_key = "FIXME"
  })
}
