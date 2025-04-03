resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-mastodon_vapid-key" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-mastodon/vapid-key"
  disable_read = true
  data_json = jsonencode({
    VAPID_PRIVATE_KEY = "FIXME"
    VAPID_PUBLIC_KEY  = "FIXME"
  })
}

resource "random_password" "k8s-k3s-fsn-lama-tel_services-mastodon_secrets" {
  count   = 2
  length  = 128
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-lama-tel_services-mastodon_secrets" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.lama.tel"].path}/services-mastodon/secrets"
  data_json = jsonencode({
    SECRET_KEY_BASE = random_password.k8s-k3s-fsn-lama-tel_services-mastodon_secrets[0].result
    OTP_SECRET      = random_password.k8s-k3s-fsn-lama-tel_services-mastodon_secrets[0].result
  })
}
