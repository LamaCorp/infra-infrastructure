resource "vault_mount" "apps" {
  path = "apps"
  type = "kv-v2"
}
