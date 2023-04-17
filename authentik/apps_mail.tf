resource "authentik_user" "mail" {
  username = "mail"
  name     = "Mail"
  email    = "postmaster@lama-corp.space"
  path     = "services/lama-corp"
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
  })
}

resource "authentik_group" "mail-ldapsearch" {
  name = "app_mail_ldapsearch"
  users = [
    authentik_user.mail.id,
  ]
}
resource "authentik_provider_ldap" "mail-ldap" {
  name      = "mail-ldap"
  bind_flow = data.authentik_flow.default-authentication-flow.id

  base_dn      = "dc=mail,dc=lama-corp,dc=space"
  search_group = authentik_group.mail-ldapsearch.id

  bind_mode   = "cached"
  search_mode = "cached"
}

resource "authentik_application" "mail-ldap" {
  name               = "Mail"
  slug               = "mail-ldap"
  group              = "Services"
  protocol_provider  = authentik_provider_ldap.mail-ldap.id
  meta_launch_url    = "blank://blank"
  policy_engine_mode = "any"
}

resource "authentik_outpost" "mail-ldap" {
  name = "mail-ldap"
  type = "ldap"
  protocol_providers = [
    authentik_provider_ldap.mail-ldap.id
  ]
  config = jsonencode({
    authentik_host   = "https://auth.lama-corp.space"
    docker_network   = "host"
    docker_map_ports = false
  })
}

data "authentik_user" "mail-ldap-outpost" {
  username = "ak-outpost-${replace(authentik_outpost.mail-ldap.id, "-", "")}"
}

resource "authentik_token" "mail-ldap-outpost" {
  identifier = "ak-outpost-${authentik_outpost.mail-ldap.id}-api-manual"
  user       = data.authentik_user.mail-ldap-outpost.id
  intent     = "api"
  expiring   = false

  retrieve_key = true
}

resource "authentik_token" "mail-ldapsearch" {
  identifier = "mail"
  user       = authentik_user.mail.id
  intent     = "app_password"
  expiring   = false

  retrieve_key = true
}

resource "vault_generic_secret" "authentik_apps_mail_ldap" {
  path = "authentik/apps/mail/ldap"
  data_json = jsonencode({
    username      = authentik_user.mail.username
    bind_password = authentik_token.mail-ldapsearch.key
    outpost_token = authentik_token.mail-ldap-outpost.key
  })
}
