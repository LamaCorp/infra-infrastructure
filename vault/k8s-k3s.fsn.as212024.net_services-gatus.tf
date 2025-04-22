resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-gatus-devoups_secrets" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-gatus-devoups/secrets"
  disable_read = true
  data_json = jsonencode({
    slack_webhook_url = "FIXME"
  })
}

resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-gatus-phowork_secrets" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-gatus-phowork/secrets"
  disable_read = true
  data_json = jsonencode({
    alerting_api_key = "FIXME"
  })
}

resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-gatus-prologin_secrets" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-gatus-prologin/secrets"
  disable_read = true
  data_json = jsonencode({
    discord_webhook_url = "FIXME"
  })
}
