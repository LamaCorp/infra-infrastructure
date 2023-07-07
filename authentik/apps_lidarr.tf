resource "authentik_provider_proxy" "lidarr" {
  name                  = "lidarr"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "hours=24"
  mode                  = "forward_single"
  external_host         = "https://lidarr.lama-corp.space"
}

resource "authentik_application" "lidarr" {
  name               = "lidarr"
  slug               = "lidarr"
  group              = "Media"
  protocol_provider  = authentik_provider_proxy.lidarr.id
  policy_engine_mode = "any"

  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/lidarr.png"
  meta_description = "Movies"
}

resource "authentik_outpost" "lidarr-proxy" {
  name = "lidarr-proxy"
  type = "proxy"
  protocol_providers = [
    authentik_provider_proxy.lidarr.id,
  ]
  config = jsonencode({
    authentik_host   = "https://auth.lama-corp.space"
    docker_network   = "reverse_proxy"
    docker_map_ports = false
    docker_labels = {
      "traefik.http.routers.ak-outpost-lidarr-proxy-router.tls.options"      = "intermediate@file"
      "traefik.http.routers.ak-outpost-lidarr-proxy-router.tls.certresolver" = "letsEncrypt"
    }
  })
  service_connection = authentik_service_connection_docker.local.id
}
