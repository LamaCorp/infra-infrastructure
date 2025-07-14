resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-media_qbittorrent_vpn" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-media/qbittorrent/vpn"
  disable_read = true
  data_json = jsonencode({
    "wg0.conf" = "FIXME: get this from Proton VPN"
  })
}
