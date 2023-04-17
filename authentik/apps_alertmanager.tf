locals {
  alertmanager_allowed_groups = [
    "roots",
  ]
}

resource "authentik_provider_proxy" "alertmanager" {
  name               = "alertmanager"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  mode               = "forward_single"
  external_host      = "https://alerts.lama.tel"
}

resource "authentik_application" "alertmanager" {
  name               = "Alertmanager"
  slug               = "alertmanager"
  group              = "Infra"
  protocol_provider  = authentik_provider_proxy.alertmanager.id
  policy_engine_mode = "any"

  meta_launch_url  = "https://alerts.lama.tel"
  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/alertmanager.png"
  meta_description = "Infrastructure alerts"
}

resource "authentik_policy_binding" "alertmanager_group-filtering" {
  for_each = { for idx, value in local.alertmanager_allowed_groups : idx => value }

  target = authentik_application.alertmanager.uuid
  group  = data.authentik_group.groups[each.value].id
  order  = each.key
}

resource "authentik_outpost" "alertmanager" {
  name = "alertmanager"
  type = "proxy"
  protocol_providers = [
    authentik_provider_proxy.alertmanager.id,
  ]
  config = jsonencode({
    authentik_host   = "https://auth.lama.tel"
    docker_network   = "reverse_proxy"
    docker_map_ports = false
    docker_labels = {
      "traefik.http.routers.ak-outpost-alertmanager-router.tls.options"      = "modern@file"
      "traefik.http.routers.ak-outpost-alertmanager-router.tls.certresolver" = "letsEncrypt"
    }
  })
  service_connection = authentik_service_connection_docker.local.id
}
