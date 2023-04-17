resource "vault_generic_secret" "infra_aws_root" {
  path         = "${vault_mount.infra.path}/aws/root"
  disable_read = true
  data_json = jsonencode({
    access_key = "FIXME: get one from the AWS console"
    secret_key = "FIXME: get one from the AWS console"
  })
}
