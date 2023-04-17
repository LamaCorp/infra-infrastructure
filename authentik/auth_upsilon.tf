data "vault_generic_secret" "apps_upsilon_oauth-app-secret" {
  path = "apps/upsilon/oauth-app-secret"
}

resource "authentik_source_oauth" "upsilon" {
  name          = "Upsilon"
  provider_type = "openidconnect"
  slug          = "upsilon"

  authentication_flow = data.authentik_flow.default-source-authentication.id
  enrollment_flow     = data.authentik_flow.default-source-enrollment.id
  user_matching_mode  = "email_link"

  consumer_key        = "authentik"
  consumer_secret     = data.vault_generic_secret.apps_upsilon_oauth-app-secret.data["client_secret"]
  oidc_well_known_url = "https://upsilon.pie.lama-corp.space/o/.well-known/openid-configuration/"

  lifecycle {
    ignore_changes = [
      access_token_url,
      authorization_url,
      oidc_jwks_url,
      profile_url,
    ]
  }
}
