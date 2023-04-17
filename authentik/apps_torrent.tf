locals {
  torrent_allowed_groups = [
    "roots",
  ]
}

resource "authentik_provider_proxy" "torrent" {
  name                  = "torrent"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "hours=24"
  mode                  = "forward_single"
  external_host         = "https://torrent.lama-corp.space"
}

resource "authentik_application" "torrent" {
  name               = "torrent"
  slug               = "torrent"
  group              = "Services"
  protocol_provider  = authentik_provider_proxy.torrent.id
  policy_engine_mode = "any"

  meta_launch_url  = "https://torrent.lama-corp.space"
  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/qbittorent.png"
  meta_description = "Torrent management"
}

resource "authentik_policy_binding" "torrent_group-filtering" {
  for_each = { for idx, value in local.torrent_allowed_groups : idx => value }
  target   = authentik_application.torrent.uuid
  group    = data.authentik_group.groups[each.value].id
  order    = each.key
}

resource "authentik_outpost" "torrent-proxy" {
  name = "torrent-proxy"
  type = "proxy"
  protocol_providers = [
    authentik_provider_proxy.torrent.id,
  ]
  config = jsonencode({
    authentik_host   = "https://auth.lama-corp.space"
    docker_network   = "reverse_proxy"
    docker_map_ports = false
    docker_labels = {
      "traefik.http.routers.ak-outpost-torrent-proxy-router.tls.options"      = "modern@file"
      "traefik.http.routers.ak-outpost-torrent-proxy-router.tls.certresolver" = "letsEncrypt"
    }
  })
  service_connection = authentik_service_connection_docker.local.id
}
