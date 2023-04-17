resource "vault_generic_secret" "infra_gitlab-runner_registration-tokens_lama-corp" {
  path         = "${vault_mount.infra.path}/gitlab-runner/registration-tokens/lama-corp"
  disable_read = true
  data_json = jsonencode({
    token = "FIXME"
  })
}
