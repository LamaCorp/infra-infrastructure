resource "random_string" "jellyfin-oidc" {
  count   = 2
  length  = 64
  special = false
}

resource "authentik_provider_oauth2" "jellyfin-oidc" {
  name               = "jellyfin-oidc"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.jellyfin-oidc[0].result
  client_secret      = random_string.jellyfin-oidc[1].result

  access_code_validity   = "hours=1"
  refresh_token_validity = "days=30"

  sub_mode = "user_email"

  redirect_uris = [
    "https://jellyfin.lama-corp.space/sso/OID/r/Lama",
  ]

  property_mappings = [
    authentik_scope_mapping.scope-email-primary-address.id,
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
  ]

  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "jellyfin-oidc" {
  name               = "Jellyfin"
  slug               = "jellyfin"
  group              = "Media"
  protocol_provider  = authentik_provider_oauth2.jellyfin-oidc.id
  policy_engine_mode = "any"

  meta_launch_url  = "https://jellyfin.lama-corp.space/sso/OID/p/Lama"
  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/jellyfin.png"
  meta_description = "Media player"
}

resource "vault_generic_secret" "authentik_apps_jellyfin_oidc" {
  path = "authentik/apps/jellyfin/oidc"
  data_json = jsonencode({
    client_id = authentik_provider_oauth2.jellyfin-oidc.client_id
    secret_id = authentik_provider_oauth2.jellyfin-oidc.client_secret
  })
}
