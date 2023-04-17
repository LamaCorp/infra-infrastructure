resource "vault_mount" "acme" {
  path = "acme"
  type = "kv-v2"
}
resource "vault_generic_secret" "acme_cloudflare-token" {
  path         = "${vault_mount.acme.path}/cloudflare-token"
  disable_read = true
  data_json = jsonencode({
    token = "FIXME"
  })
}

resource "vault_auth_backend" "acme-approle" {
  path = "acme-approle"
  type = "approle"
}

resource "vault_policy" "acme_secure-services_fsn_lama_tel" {
  name = "acme_secure-services.fsn.lama.tel"

  policy = <<-EOF
    path "acme/data/certs/*" {
       capabilities = ["create", "read", "update", "list"]
    }
    path "acme/metadata/certs/*" {
       capabilities = ["create", "read", "update", "list"]
    }
  EOF
}
resource "vault_approle_auth_backend_role" "acme_secure-services_fsn_lama_tel" {
  backend        = vault_auth_backend.acme-approle.path
  role_name      = "acme_secure-services.fsn.lama.tel"
  token_policies = [vault_policy.acme_secure-services_fsn_lama_tel.name]
}
resource "vault_approle_auth_backend_role_secret_id" "acme_secure-services_fsn_lama_tel" {
  backend   = vault_auth_backend.acme-approle.path
  role_name = vault_approle_auth_backend_role.acme_secure-services_fsn_lama_tel.role_name
}
resource "vault_generic_secret" "acme_server-creds_secure-services_fsn_lama_tel" {
  path = "acme/server-creds/secure-services.fsn.lama.tel"
  data_json = jsonencode({
    role_id   = vault_approle_auth_backend_role.acme_secure-services_fsn_lama_tel.role_id
    secret_id = vault_approle_auth_backend_role_secret_id.acme_secure-services_fsn_lama_tel.secret_id
  })
}


resource "vault_policy" "acme_mail_fsn_lama_tel" {
  name = "acme_mail.fsn.lama.tel"

  policy = <<-EOF
    path "acme/data/certs/mail-1.lama-corp.space" {
       capabilities = ["read"]
    }
    path "acme/metadata/certs/mail-1.lama-corp.space" {
       capabilities = ["read"]
    }
  EOF
}
resource "vault_approle_auth_backend_role" "acme_mail_fsn_lama_tel" {
  backend        = vault_auth_backend.acme-approle.path
  role_name      = "acme_mail.fsn.lama.tel"
  token_policies = [vault_policy.acme_mail_fsn_lama_tel.name]
}
resource "vault_approle_auth_backend_role_secret_id" "acme_mail_fsn_lama_tel" {
  backend   = vault_auth_backend.acme-approle.path
  role_name = vault_approle_auth_backend_role.acme_mail_fsn_lama_tel.role_name
}
resource "vault_generic_secret" "acme_server-creds_mail_fsn_lama_tel" {
  path = "acme/server-creds/mail.fsn.lama.tel"
  data_json = jsonencode({
    role_id   = vault_approle_auth_backend_role.acme_mail_fsn_lama_tel.role_id
    secret_id = vault_approle_auth_backend_role_secret_id.acme_mail_fsn_lama_tel.secret_id
  })
}

resource "vault_policy" "acme_postgresql_fsn_lama_tel" {
  name = "acme_postgresql.fsn.lama.tel"

  policy = <<-EOF
    path "acme/data/certs/postgresql.fsn.lama.tel" {
       capabilities = ["read"]
    }
    path "acme/metadata/certs/postgresql.fsn.lama.tel" {
       capabilities = ["read"]
    }
  EOF
}
resource "vault_approle_auth_backend_role" "acme_postgresql_fsn_lama_tel" {
  backend        = vault_auth_backend.acme-approle.path
  role_name      = "acme_postgresql.fsn.lama.tel"
  token_policies = [vault_policy.acme_postgresql_fsn_lama_tel.name]
}
resource "vault_approle_auth_backend_role_secret_id" "acme_postgresql_fsn_lama_tel" {
  backend   = vault_auth_backend.acme-approle.path
  role_name = vault_approle_auth_backend_role.acme_postgresql_fsn_lama_tel.role_name
}
resource "vault_generic_secret" "acme_server-creds_postgresql_fsn_lama_tel" {
  path = "acme/server-creds/postgresql.fsn.lama.tel"
  data_json = jsonencode({
    role_id   = vault_approle_auth_backend_role.acme_postgresql_fsn_lama_tel.role_id
    secret_id = vault_approle_auth_backend_role_secret_id.acme_postgresql_fsn_lama_tel.secret_id
  })
}

resource "vault_policy" "acme_services_fsn_lama_tel" {
  name = "acme_services.fsn.lama.tel"

  policy = <<-EOF
    path "acme/data/certs/*" {
       capabilities = ["read"]
    }
    path "acme/metadata/certs/*" {
       capabilities = ["read"]
    }
  EOF
}
resource "vault_approle_auth_backend_role" "acme_services_fsn_lama_tel" {
  backend        = vault_auth_backend.acme-approle.path
  role_name      = "acme_services.fsn.lama.tel"
  token_policies = [vault_policy.acme_services_fsn_lama_tel.name]
}
resource "vault_approle_auth_backend_role_secret_id" "acme_services_fsn_lama_tel" {
  backend   = vault_auth_backend.acme-approle.path
  role_name = vault_approle_auth_backend_role.acme_services_fsn_lama_tel.role_name
}
resource "vault_generic_secret" "acme_server-creds_services_fsn_lama_tel" {
  path = "acme/server-creds/services.fsn.lama.tel"
  data_json = jsonencode({
    role_id   = vault_approle_auth_backend_role.acme_services_fsn_lama_tel.role_id
    secret_id = vault_approle_auth_backend_role_secret_id.acme_services_fsn_lama_tel.secret_id
  })
}
