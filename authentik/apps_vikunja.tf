resource "random_string" "vikunja-oidc" {
  count   = 2
  length  = 64
  special = false
}

resource "authentik_provider_oauth2" "vikunja-oidc" {
  name               = "vikunja-oidc"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.vikunja-oidc[0].result
  client_secret      = random_string.vikunja-oidc[1].result

  access_code_validity   = "hours=1"
  refresh_token_validity = "days=30"

  sub_mode = "user_email"

  redirect_uris = [
    "https://tasks.lama-corp.space/auth/openid/lamacorp",
  ]

  property_mappings = [
    authentik_scope_mapping.scope-email-primary-address.id,
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
  ]

  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "vikunja-oidc" {
  name               = "Vikunja"
  slug               = "vikunja"
  group              = "Services"
  protocol_provider  = authentik_provider_oauth2.vikunja-oidc.id
  policy_engine_mode = "any"

  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/vikunja.png"
  meta_description = "Gestion de tâches"
}

resource "vault_generic_secret" "authentik_apps_vikunja_oidc" {
  path = "authentik/apps/vikunja/oidc"
  data_json = jsonencode({
    client_id = authentik_provider_oauth2.vikunja-oidc.client_id
    secret_id = authentik_provider_oauth2.vikunja-oidc.client_secret
  })
}
