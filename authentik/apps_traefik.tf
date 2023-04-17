locals {
  traefik_allowed_groups = [
    "roots",
  ]
}

resource "authentik_provider_proxy" "traefik" {
  name               = "traefik"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  mode               = "forward_single"
  external_host      = "https://traefik.lama.tel"
}

resource "authentik_application" "traefik" {
  name               = "Traefik"
  slug               = "traefik"
  group              = "Infra"
  protocol_provider  = authentik_provider_proxy.traefik.id
  policy_engine_mode = "any"

  meta_launch_url  = "https://traefik.lama.tel"
  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/traefik.png"
  meta_description = "Reverse proxy"
}

resource "authentik_policy_binding" "traefik_group-filtering" {
  for_each = { for idx, value in local.traefik_allowed_groups : idx => value }
  target   = authentik_application.traefik.uuid
  group    = data.authentik_group.groups[each.value].id
  order    = each.key
}

resource "authentik_outpost" "traefik" {
  name = "traefik"
  type = "proxy"
  protocol_providers = [
    authentik_provider_proxy.traefik.id,
  ]
  config = jsonencode({
    authentik_host   = "https://auth.lama.tel"
    docker_network   = "reverse_proxy"
    docker_map_ports = false
    docker_labels = {
      "traefik.http.routers.ak-outpost-traefik-router.tls.options"      = "modern@file"
      "traefik.http.routers.ak-outpost-traefik-router.tls.certresolver" = "letsEncrypt"
    }
  })
  service_connection = authentik_service_connection_docker.local.id
}
