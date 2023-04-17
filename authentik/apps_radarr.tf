resource "authentik_provider_proxy" "radarr" {
  name                  = "radarr"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "hours=24"
  mode                  = "forward_single"
  external_host         = "https://radarr.lama-corp.space"
}

resource "authentik_application" "radarr" {
  name               = "Radarr"
  slug               = "radarr"
  group              = "Services"
  protocol_provider  = authentik_provider_proxy.radarr.id
  policy_engine_mode = "any"

  meta_launch_url  = "https://radarr.lama-corp.space"
  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/radarr.png"
  meta_description = "Movies"
}

resource "authentik_outpost" "radarr-proxy" {
  name = "radarr-proxy"
  type = "proxy"
  protocol_providers = [
    authentik_provider_proxy.radarr.id,
  ]
  config = jsonencode({
    authentik_host   = "https://auth.lama-corp.space"
    docker_network   = "reverse_proxy"
    docker_map_ports = false
    docker_labels = {
      "traefik.http.routers.ak-outpost-radarr-proxy-router.tls.options"      = "intermediate@file"
      "traefik.http.routers.ak-outpost-radarr-proxy-router.tls.certresolver" = "letsEncrypt"
    }
  })
  service_connection = authentik_service_connection_docker.local.id
}
