resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-gitlab-runner_registration_lama-corp" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-gitlab-runner/registration/lama-corp"
  disable_read = true
  data_json = jsonencode({
    runner-registration-token = ""
    runner-token              = "FIXME: get this from GitLab.com"
  })
}
