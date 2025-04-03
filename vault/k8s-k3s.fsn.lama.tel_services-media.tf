resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-media_qbittorrent_vpn" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-media/qbittorrent/vpn"
  disable_read = true
  data_json = jsonencode({
    "wg0.conf" = "FIXME: get this from Proton VPN"
  })
}

resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-media_sabnzbd_vpn" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-media/sabnzbd/vpn"
  disable_read = true
  data_json = jsonencode({
    "wg0.conf" = "FIXME: get this from Proton VPN"
  })
}
