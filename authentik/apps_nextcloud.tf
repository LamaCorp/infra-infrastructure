resource "tls_private_key" "nextcloud-saml" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "nextcloud-saml" {
  private_key_pem = tls_private_key.nextcloud-saml.private_key_pem

  subject {
    common_name  = "cloud.lama-corp.space"
    organization = "Lama Corp."
  }

  validity_period_hours = 24 * 365 * 10 # 10y

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "authentik_certificate_key_pair" "nextcloud-saml" {
  name             = "nextcloud-saml"
  certificate_data = tls_self_signed_cert.nextcloud-saml.cert_pem
  key_data         = tls_private_key.nextcloud-saml.private_key_pem
}

resource "authentik_provider_saml" "nextcloud-saml" {
  name               = "nextcloud-saml"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  acs_url            = "https://cloud.lama-corp.space/apps/user_saml/saml/acs"
  issuer             = "https://auth.lama-corp.space"
  audience           = "https://cloud.lama-corp.space/apps/user_saml/saml/metadata"
  sp_binding         = "post"
  signing_kp         = data.authentik_certificate_key_pair.default.id
  verification_kp    = authentik_certificate_key_pair.nextcloud-saml.id

  assertion_valid_not_before = "minutes=-3"

  name_id_mapping = data.authentik_property_mapping_saml.username.id
  property_mappings = [
    data.authentik_property_mapping_saml.upn.id,
    data.authentik_property_mapping_saml.name.id,
    data.authentik_property_mapping_saml.email.id,
    data.authentik_property_mapping_saml.username.id,
    data.authentik_property_mapping_saml.uid.id,
    authentik_property_mapping_saml.nextcloud-groups.id,
    authentik_property_mapping_saml.nextcloud-quota.id,
  ]
}
resource "authentik_property_mapping_saml" "nextcloud-groups" {
  name       = "SAML NextCloud Groups"
  saml_name  = "http://schemas.xmlsoap.org/claims/Group"
  expression = <<-EOT
    for group in user.ak_groups.all():
      yield group.name
    if ak_is_group_member(request.user, name="roots"):
      yield "admin"
  EOT
}
resource "authentik_property_mapping_saml" "nextcloud-quota" {
  name       = "SAML NextCloud Quota"
  saml_name  = "nextcloud_quota"
  expression = <<-EOT
    return user.group_attributes().get("nextcloud_quota", "default")
  EOT
}

resource "authentik_application" "nextcloud" {
  name               = "Nextcloud"
  slug               = "nextcloud"
  group              = "Services"
  protocol_provider  = authentik_provider_saml.nextcloud-saml.id
  policy_engine_mode = "any"

  meta_launch_url  = "https://cloud.lama-corp.space"
  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/nextcloud.png"
  meta_description = "Stockage de fichiers"
}


resource "authentik_user" "nextcloud" {
  username = "nextcloud"
  name     = "Nextcloud"
  email    = "no-reply@cloud.lama-corp.space"
  path     = "services/lama-corp"
  attributes = jsonencode({
    "goauthentik.io/user/service-account" = true
  })
}

resource "authentik_group" "nextcloud-ldapsearch" {
  name = "app_nextcloud_ldapsearch"
  users = [
    authentik_user.nextcloud.id,
  ]
}
resource "authentik_provider_ldap" "nextcloud-ldap" {
  name      = "nextcloud-ldap"
  bind_flow = data.authentik_flow.default-authentication-flow.id

  base_dn      = "dc=cloud,dc=lama-corp,dc=space"
  search_group = authentik_group.nextcloud-ldapsearch.id

  bind_mode   = "cached"
  search_mode = "cached"
}

resource "authentik_application" "nextcloud-ldap" {
  name               = "Nextcloud LDAP"
  slug               = "nextcloud-ldap"
  group              = "Services"
  protocol_provider  = authentik_provider_ldap.nextcloud-ldap.id
  meta_launch_url    = "blank://blank"
  policy_engine_mode = "any"
}

resource "authentik_outpost" "nextcloud-ldap" {
  name = "nextcloud-ldap"
  type = "ldap"
  protocol_providers = [
    authentik_provider_ldap.nextcloud-ldap.id
  ]
  config = jsonencode({
    authentik_host   = "https://auth.lama-corp.space"
    docker_network   = "nextcloud_default"
    docker_map_ports = false
  })
  service_connection = authentik_service_connection_docker.local.id
}

resource "authentik_token" "nextcloud-ldapsearch" {
  identifier = "nextcloud"
  user       = authentik_user.nextcloud.id
  intent     = "app_password"
  expiring   = false

  retrieve_key = true
}

resource "vault_generic_secret" "authentik_apps_nextcloud_ldap" {
  path = "authentik/apps/nextcloud/ldap"
  data_json = jsonencode({
    username      = authentik_user.nextcloud.username
    bind_password = authentik_token.nextcloud-ldapsearch.key
  })
}
