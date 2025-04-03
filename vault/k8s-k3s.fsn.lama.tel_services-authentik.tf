resource "random_password" "k8s-k3s-fsn-lama-tel_services-authentik_admin" {
  count   = 2
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-authentik_admin" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-authentik/admin"
  data_json = jsonencode({
    password = random_password.k8s-k3s-fsn-lama-tel_services-authentik_admin[0].result
    token    = random_password.k8s-k3s-fsn-lama-tel_services-authentik_admin[1].result
  })
}

resource "random_password" "k8s-k3s-fsn-lama-tel_services-authentik_secrets" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-authentik_secrets" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-authentik/secrets"
  data_json = jsonencode({
    secret-key = random_password.k8s-k3s-fsn-lama-tel_services-authentik_secrets[0].result
  })
}

resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-authentik_blueprint-secrets" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-authentik/blueprint-secrets"
  disable_read = true
  data_json = jsonencode({
    AUTHENTIK_BLUEPRINTS_NOTIFICATIONS_SLACK_WEBHOOK = "FIXME"
  })
}

resource "random_password" "k8s-k3s-fsn-lama-tel_services-authentik_kdc_secrets" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-authentik_kdc_secrets" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-authentik/kdc/secrets"
  data_json = jsonencode({
    master-password = random_password.k8s-k3s-fsn-lama-tel_services-authentik_secrets[0].result
  })
}
