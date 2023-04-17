resource "vault_audit" "audit" {
  type = "file"

  options = {
    file_path = "/vault/logs/audit.log"
  }
}
