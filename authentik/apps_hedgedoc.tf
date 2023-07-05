resource "random_string" "hedgedoc-oidc" {
  count   = 2
  length  = 64
  special = false
}

resource "authentik_provider_oauth2" "hedgedoc-oidc" {
  name               = "hedgedoc-oidc"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.hedgedoc-oidc[0].result
  client_secret      = random_string.hedgedoc-oidc[1].result

  access_code_validity   = "hours=1"
  refresh_token_validity = "days=30"

  sub_mode = "user_email"

  redirect_uris = [
    "https://md.lama-corp.space/auth/oauth2/callback",
  ]

  property_mappings = [
    data.authentik_scope_mapping.scope-email.id,
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
  ]

  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "hedgedoc-oidc" {
  name               = "Hedgedoc"
  slug               = "hedgedoc"
  group              = "Services"
  protocol_provider  = authentik_provider_oauth2.hedgedoc-oidc.id
  policy_engine_mode = "any"

  meta_icon        = "https://github.com/hedgedoc/hedgedoc-logo/raw/main/LOGOTYPE/PNG/HedgeDoc-Logo%201.png"
  meta_description = "Éditeur de texte collaboratif"
}

resource "vault_generic_secret" "authentik_apps_hedgedoc_oidc" {
  path = "authentik/apps/hedgedoc/oidc"
  data_json = jsonencode({
    client_id = authentik_provider_oauth2.hedgedoc-oidc.client_id
    secret_id = authentik_provider_oauth2.hedgedoc-oidc.client_secret
  })
}
