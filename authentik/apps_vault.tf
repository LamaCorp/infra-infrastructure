locals {
  vault_allowed_groups = [
    "roots",
  ]
}

resource "random_string" "vault-oidc" {
  count   = 2
  length  = 64
  special = false
}

resource "authentik_provider_oauth2" "vault-oidc" {
  name               = "vault-oidc"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.vault-oidc[0].result
  client_secret      = random_string.vault-oidc[1].result

  access_code_validity   = "hours=1"
  refresh_token_validity = "days=30"

  sub_mode = "hashed_user_id"

  redirect_uris = [
    "https://vault.lama.tel/ui/vault/auth/authentik/oidc/callback",
    "https://vault.lama.tel/oidc/callback",
    "http://localhost:8250/oidc/callback",
  ]

  property_mappings = [
    data.authentik_scope_mapping.scope-email.id,
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
  ]

  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "vault-oidc" {
  name               = "Vault"
  slug               = "vault"
  group              = "Infra"
  protocol_provider  = authentik_provider_oauth2.vault-oidc.id
  policy_engine_mode = "any"

  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/vault.png"
  meta_description = "Secret storage"
}

resource "authentik_policy_binding" "vault_group-filtering" {
  for_each = { for idx, value in local.vault_allowed_groups : idx => value }

  target = authentik_application.vault-oidc.uuid
  group  = data.authentik_group.groups[each.value].id
  order  = each.key
}

resource "vault_jwt_auth_backend" "authentik" {
  path = "authentik"
  type = "oidc"

  oidc_discovery_url = "https://auth.lama.tel/application/o/vault/"
  oidc_client_id     = authentik_provider_oauth2.vault-oidc.client_id
  oidc_client_secret = authentik_provider_oauth2.vault-oidc.client_secret
  default_role       = "authentik"

  tune {
    listing_visibility = "unauth"
    default_lease_ttl  = "24h"
    max_lease_ttl      = "24h"
    token_type         = "default-service"
  }
}

resource "vault_jwt_auth_backend_role" "authentik" {
  backend        = vault_jwt_auth_backend.authentik.path
  role_name      = "authentik"
  token_policies = ["default"]

  oidc_scopes  = ["profile", "email"]
  groups_claim = "groups"
  user_claim   = "sub"
  role_type    = "oidc"

  allowed_redirect_uris = authentik_provider_oauth2.vault-oidc.redirect_uris
}

resource "vault_policy" "admin" {
  name   = "admin"
  policy = <<EOF
    path "*" {
      capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
    }
  EOF
}

resource "vault_identity_group" "admins" {
  name     = "admins"
  type     = "external"
  policies = [vault_policy.admin.name]

  metadata = {
    version = "1"
  }
}

resource "vault_identity_group_alias" "roots" {
  name           = "roots"
  mount_accessor = vault_jwt_auth_backend.authentik.accessor
  canonical_id   = vault_identity_group.admins.id
}
