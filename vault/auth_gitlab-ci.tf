resource "vault_jwt_auth_backend" "gitlab-ci" {
  description  = "GitLab CI authentication"
  path         = "gitlab-ci"
  bound_issuer = "gitlab.com"
  jwks_url     = "https://gitlab.com/-/jwks"
}
