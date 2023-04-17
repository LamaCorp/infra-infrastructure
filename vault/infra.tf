resource "vault_mount" "infra" {
  path = "infra"
  type = "kv-v2"
}
