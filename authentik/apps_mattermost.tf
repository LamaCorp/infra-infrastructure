resource "random_string" "mattermost-oidc" {
  count   = 2
  length  = 64
  special = false
}

resource "authentik_provider_oauth2" "mattermost-oidc" {
  name               = "mattermost-oidc"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.mattermost-oidc[0].result
  client_secret      = random_string.mattermost-oidc[1].result

  access_code_validity   = "hours=1"
  refresh_token_validity = "days=30"

  sub_mode = "user_email"

  redirect_uris = [
    "https://chat.lama-corp.space/signup/gitlab/complete",
  ]

  property_mappings = [
    authentik_scope_mapping.scope-email-primary-address.id,
    authentik_scope_mapping.scope-user-pk.id,
    authentik_scope_mapping.scope-username.id,
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
  ]

  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "mattermost-oidc" {
  name               = "Mattermost"
  slug               = "mattermost"
  group              = "Services"
  protocol_provider  = authentik_provider_oauth2.mattermost-oidc.id
  policy_engine_mode = "any"

  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/mattermost.png"
  meta_description = "Messagerie instantannée d'équipe"
}

resource "vault_generic_secret" "authentik_apps_mattermost_oidc" {
  path = "authentik/apps/mattermost/oidc"
  data_json = jsonencode({
    client_id = authentik_provider_oauth2.mattermost-oidc.client_id
    secret_id = authentik_provider_oauth2.mattermost-oidc.client_secret
  })
}
