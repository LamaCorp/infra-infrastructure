resource "vault_auth_backend" "authentik" {
  path = "authentik"
  type = "oidc"

  tune {
    listing_visibility = "unauth"
    default_lease_ttl  = "24h"
    max_lease_ttl      = "24h"
    token_type         = "default-service"
  }
}

resource "vault_jwt_auth_backend_role" "authentik" {
  backend        = vault_auth_backend.authentik.path
  role_name      = "authentik"
  token_policies = ["default"]

  oidc_scopes  = ["profile", "email"]
  groups_claim = "groups"
  user_claim   = "sub"
  role_type    = "oidc"

  allowed_redirect_uris = [
    "https://vault.as212024.net/ui/vault/auth/authentik/oidc/callback",
    "https://vault.as212024.net/oidc/callback",
    "http://localhost:8250/oidc/callback",
  ]
}

resource "vault_identity_group_alias" "roots" {
  name           = "roots"
  mount_accessor = vault_auth_backend.authentik.accessor
  canonical_id   = vault_identity_group.admins.id
}
