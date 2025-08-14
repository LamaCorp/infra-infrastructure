resource "vault_mount" "databases" {
  path = "databases"
  type = "kv-v2"
}
