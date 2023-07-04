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
  group              = "Services"
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


resource "authentik_user" "jellyfin" {
  username = "jellyfin"
  name     = "jellyfin"
  email    = "no-reply@jellyfin.lama-corp.space"
  path     = "services/lama-corp"
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
  })
}

resource "authentik_group" "jellyfin-ldapsearch" {
  name = "app_jellyfin_ldapsearch"
  users = [
    authentik_user.jellyfin.id,
  ]
}
resource "authentik_provider_ldap" "jellyfin-ldap" {
  name      = "jellyfin-ldap"
  bind_flow = data.authentik_flow.default-authentication-flow.id

  base_dn      = "dc=jellyfin,dc=lama-corp,dc=space"
  search_group = authentik_group.jellyfin-ldapsearch.id

  bind_mode   = "direct"
  search_mode = "direct"
}

resource "authentik_application" "jellyfin-ldap" {
  name               = "Jellyfin"
  slug               = "jellyfin-ldap"
  group              = "Services"
  protocol_provider  = authentik_provider_ldap.jellyfin-ldap.id
  policy_engine_mode = "any"

  meta_launch_url = "blank://blank"
}

resource "authentik_outpost" "jellyfin-ldap" {
  name = "jellyfin-ldap"
  type = "ldap"
  protocol_providers = [
    authentik_provider_ldap.jellyfin-ldap.id
  ]
  config = jsonencode({
    authentik_host   = "https://auth.lama-corp.space"
    docker_network   = "jellyfin_default"
    docker_map_ports = false
  })
  service_connection = authentik_service_connection_docker.local.id
}

resource "authentik_token" "jellyfin-ldapsearch" {
  identifier = "jellyfin"
  user       = authentik_user.jellyfin.id
  intent     = "app_password"
  expiring   = false

  retrieve_key = true
}

resource "vault_generic_secret" "authentik_apps_jellyfin_ldap" {
  path = "authentik/apps/jellyfin/ldap"
  data_json = jsonencode({
    username      = authentik_user.jellyfin.username
    bind_password = authentik_token.jellyfin-ldapsearch.key
  })
}
