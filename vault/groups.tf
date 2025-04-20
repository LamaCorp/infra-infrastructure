resource "vault_identity_group" "admins" {
  name     = "admins"
  type     = "external"
  policies = [vault_policy.admin.name]

  metadata = {
    version = "1"
  }
}
