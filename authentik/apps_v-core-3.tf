locals {
  alertmanager_allowed_users = [
    "risson",
  ]
}

resource "authentik_provider_proxy" "v-core-3" {
  name               = "v-core-3"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  mode               = "forward_single"
  external_host      = "https://v-core-3.workshop.risson.space"
  skip_path_regex    = <<EOF
    ^/webcam/webrtc$
  EOF
}

resource "authentik_application" "v-core-3" {
  name               = "V-Core 3"
  slug               = "v-core-3"
  group              = "Workshop"
  protocol_provider  = authentik_provider_proxy.v-core-3.id
  policy_engine_mode = "any"

  meta_icon        = "https://ratrig.com/media/favicon/default/square_icon_1_1.png"
  meta_description = "3D printer"
}

resource "authentik_policy_binding" "v-core-3_user-filtering" {
  for_each = { for idx, value in local.alertmanager_allowed_users : idx => value }

  target = authentik_application.v-core-3.uuid
  user   = data.authentik_user.users[each.value].id
  order  = each.key
}

resource "authentik_outpost" "v-core-3" {
  name = "v-core-3-proxy"
  type = "proxy"
  protocol_providers = [
    authentik_provider_proxy.v-core-3.id,
  ]
  config = jsonencode({
    authentik_host   = "https://auth.lama-corp.space"
    docker_network   = "reverse_proxy"
    docker_map_ports = false
    docker_labels = {
      "traefik.http.routers.ak-outpost-alertmanager-router.tls.options"      = "modern@file"
      "traefik.http.routers.ak-outpost-alertmanager-router.tls.certresolver" = "letsEncrypt"
    }
  })
  service_connection = authentik_service_connection_docker.local.id
}
