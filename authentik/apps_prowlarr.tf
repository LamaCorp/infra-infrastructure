locals {
  prowlarr_allowed_groups = [
    "roots",
  ]
}

resource "authentik_provider_proxy" "prowlarr" {
  name                  = "prowlarr"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "hours=24"
  mode                  = "forward_single"
  external_host         = "https://prowlarr.lama-corp.space"
}

resource "authentik_application" "prowlarr" {
  name               = "prowlarr"
  slug               = "prowlarr"
  group              = "Media"
  protocol_provider  = authentik_provider_proxy.prowlarr.id
  policy_engine_mode = "any"

  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/prowlarr.png"
  meta_description = "Movies"
}

resource "authentik_policy_binding" "prowlarr_group-filtering" {
  for_each = { for idx, value in local.prowlarr_allowed_groups : idx => value }
  target   = authentik_application.prowlarr.uuid
  group    = data.authentik_group.groups[each.value].id
  order    = each.key
}

resource "authentik_outpost" "prowlarr-proxy" {
  name = "prowlarr-proxy"
  type = "proxy"
  protocol_providers = [
    authentik_provider_proxy.prowlarr.id,
  ]
  config = jsonencode({
    authentik_host   = "https://auth.lama-corp.space"
    docker_network   = "reverse_proxy"
    docker_map_ports = false
    docker_labels = {
      "traefik.http.routers.ak-outpost-prowlarr-proxy-router.tls.options"      = "intermediate@file"
      "traefik.http.routers.ak-outpost-prowlarr-proxy-router.tls.certresolver" = "letsEncrypt"
    }
  })
  service_connection = authentik_service_connection_docker.local.id
}
