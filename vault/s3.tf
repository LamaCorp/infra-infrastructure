resource "vault_mount" "s3" {
  path = "s3"
  type = "kv-v2"
}
