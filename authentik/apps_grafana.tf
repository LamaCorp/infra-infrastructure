locals {
  grafana_allowed_groups = [
    "roots",
  ]
}

resource "random_string" "grafana-oidc" {
  count   = 2
  length  = 64
  special = false
}

resource "authentik_provider_oauth2" "grafana-oidc" {
  name               = "grafana-oidc"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  client_id          = random_string.grafana-oidc[0].result
  client_secret      = random_string.grafana-oidc[1].result

  access_code_validity   = "hours=1"
  refresh_token_validity = "days=30"

  sub_mode = "user_email"

  redirect_uris = [
    "https://grafana.lama.tel/login/generic_oauth",
  ]

  property_mappings = [
    data.authentik_scope_mapping.scope-email.id,
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-profile.id,
  ]

  signing_key = data.authentik_certificate_key_pair.default.id
}

resource "authentik_application" "grafana-oidc" {
  name               = "Grafana"
  slug               = "grafana"
  group              = "Infra"
  protocol_provider  = authentik_provider_oauth2.grafana-oidc.id
  policy_engine_mode = "any"

  meta_launch_url  = "https://grafana.lama.tel"
  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/grafana.png"
  meta_description = "Observability Dashboards"
}

resource "authentik_policy_binding" "grafana_group-filtering" {
  for_each = { for idx, value in local.grafana_allowed_groups : idx => value }

  target = authentik_application.grafana-oidc.uuid
  group  = data.authentik_group.groups[each.value].id
  order  = each.key
}

resource "vault_generic_secret" "authentik_apps_grafana_oidc" {
  path = "authentik/apps/grafana/oidc"
  data_json = jsonencode({
    client_id = authentik_provider_oauth2.grafana-oidc.client_id
    secret_id = authentik_provider_oauth2.grafana-oidc.client_secret
  })
}
