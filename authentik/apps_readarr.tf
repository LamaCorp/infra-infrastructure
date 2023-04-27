resource "authentik_provider_proxy" "readarr" {
  name                  = "readarr"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  access_token_validity = "hours=24"
  mode                  = "forward_single"
  external_host         = "https://readarr.lama-corp.space"
}

resource "authentik_application" "readarr" {
  name               = "readarr"
  slug               = "readarr"
  group              = "Services"
  protocol_provider  = authentik_provider_proxy.readarr.id
  policy_engine_mode = "any"

  meta_launch_url  = "https://readarr.lama-corp.space"
  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/readarr.png"
  meta_description = "Movies"
}

resource "authentik_outpost" "readarr-proxy" {
  name = "readarr-proxy"
  type = "proxy"
  protocol_providers = [
    authentik_provider_proxy.readarr.id,
  ]
  config = jsonencode({
    authentik_host   = "https://auth.lama-corp.space"
    docker_network   = "reverse_proxy"
    docker_map_ports = false
    docker_labels = {
      "traefik.http.routers.ak-outpost-readarr-proxy-router.tls.options"      = "intermediate@file"
      "traefik.http.routers.ak-outpost-readarr-proxy-router.tls.certresolver" = "letsEncrypt"
    }
  })
  service_connection = authentik_service_connection_docker.local.id
}
