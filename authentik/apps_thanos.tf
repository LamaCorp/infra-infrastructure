locals {
  thanos_allowed_groups = [
    "roots",
  ]

  thanos-bucketweb_allowed_groups = [
    "roots",
  ]
}

resource "authentik_application" "thanos" {
  name               = "Thanos"
  slug               = "thanos"
  group              = "Infra"
  policy_engine_mode = "any"

  meta_launch_url  = "https://thanos.lama.tel"
  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/thanos.png"
  meta_description = "Long-term metrics aggregator"
}

resource "authentik_policy_binding" "thanos_group-filtering" {
  for_each = { for idx, value in local.thanos_allowed_groups : idx => value }

  target = authentik_application.thanos.uuid
  group  = data.authentik_group.groups[each.value].id
  order  = each.key
}


resource "authentik_provider_proxy" "thanos-bucketweb" {
  name               = "thanos-bucketweb"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  mode               = "forward_single"
  external_host      = "https://thanos-bucketweb.lama.tel"
}

resource "authentik_application" "thanos-bucketweb" {
  name               = "Thanos Bucket Web"
  slug               = "thanos-bucketweb"
  group              = "Infra"
  protocol_provider  = authentik_provider_proxy.thanos-bucketweb.id
  policy_engine_mode = "any"

  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/thanos.png"
  meta_description = "Thanos bucket overview"
}

resource "authentik_policy_binding" "thanos-bucketweb_group-filtering" {
  for_each = { for idx, value in local.thanos-bucketweb_allowed_groups : idx => value }

  target = authentik_application.thanos-bucketweb.uuid
  group  = data.authentik_group.groups[each.value].id
  order  = each.key
}

resource "authentik_outpost" "thanos-bucketweb" {
  name = "thanos-bucketweb"
  type = "proxy"
  protocol_providers = [
    authentik_provider_proxy.thanos-bucketweb.id,
  ]
  config = jsonencode({
    authentik_host   = "https://auth.lama.tel"
    docker_network   = "reverse_proxy"
    docker_map_ports = false
    docker_labels = {
      "traefik.http.routers.ak-outpost-thanos-bucketweb-router.tls.options"      = "modern@file"
      "traefik.http.routers.ak-outpost-thanos-bucketweb-router.tls.certresolver" = "letsEncrypt"
    }
  })
  service_connection = authentik_service_connection_docker.local.id
}
