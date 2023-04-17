resource "authentik_service_connection_docker" "local" {
  name  = "local"
  local = true
}
