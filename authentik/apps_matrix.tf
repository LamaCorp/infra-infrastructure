resource "authentik_user" "matrix" {
  username = "matrix"
  name     = "matrix"
  email    = "no-reply@matrix.lama-corp.space"
  path     = "services/lama-corp"
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
  })
}

resource "authentik_group" "matrix-ldapsearch" {
  name = "app_matrix_ldapsearch"
  users = [
    authentik_user.matrix.id,
  ]
}
resource "authentik_provider_ldap" "matrix-ldap" {
  name      = "matrix-ldap"
  bind_flow = data.authentik_flow.default-authentication-flow.id

  base_dn      = "dc=matrix,dc=lama-corp,dc=space"
  search_group = authentik_group.matrix-ldapsearch.id

  bind_mode   = "direct"
  search_mode = "direct"
}

resource "authentik_application" "matrix-ldap" {
  name               = "Matrix"
  slug               = "matrix-ldap"
  group              = "Services"
  protocol_provider  = authentik_provider_ldap.matrix-ldap.id
  policy_engine_mode = "any"

  meta_launch_url  = "https://element.lama-corp.space"
  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/matrix.png"
  meta_description = "Messagerie instantanée décentralisée"
}

resource "authentik_outpost" "matrix-ldap" {
  name = "matrix-ldap"
  type = "ldap"
  protocol_providers = [
    authentik_provider_ldap.matrix-ldap.id
  ]
  config = jsonencode({
    authentik_host   = "https://auth.lama-corp.space"
    docker_network   = "matrix"
    docker_map_ports = false
  })
  service_connection = authentik_service_connection_docker.local.id
}

resource "authentik_token" "matrix-ldapsearch" {
  identifier = "matrix"
  user       = authentik_user.matrix.id
  intent     = "app_password"
  expiring   = false

  retrieve_key = true
}

resource "vault_generic_secret" "authentik_apps_matrix_ldap" {
  path = "authentik/apps/matrix/ldap"
  data_json = jsonencode({
    username      = authentik_user.matrix.username
    bind_password = authentik_token.matrix-ldapsearch.key
  })
}
