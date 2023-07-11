resource "vault_generic_secret" "apps_gatus_authentik_slack-webhook" {
  path         = "${vault_mount.apps.path}/gatus/authentik/slack-webhook"
  disable_read = true
  data_json = jsonencode({
    webhook = "FIXME"
  })
}

resource "vault_generic_secret" "apps_gatus_devoups_slack-webhook" {
  path         = "${vault_mount.apps.path}/gatus/devoups/slack-webhook"
  disable_read = true
  data_json = jsonencode({
    webhook = "FIXME"
  })
}

resource "vault_generic_secret" "apps_gatus_phowork_sms-token" {
  path         = "${vault_mount.apps.path}/gatus/phowork/sms-token"
  disable_read = true
  data_json = jsonencode({
    token = "FIXME"
  })
}

resource "vault_generic_secret" "apps_gatus_prologin_discord-webhook" {
  path         = "${vault_mount.apps.path}/gatus/prologin/discord-webhook"
  disable_read = true
  data_json = jsonencode({
    webhook = "FIXME"
  })
}
