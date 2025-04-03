resource "vault_mount" "authentik" {
  path = "authentik"
  type = "kv-v2"
}
