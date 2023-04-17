data "authentik_scope_mapping" "scope-openid" {
  managed = "goauthentik.io/providers/oauth2/scope-openid"
}

data "authentik_scope_mapping" "scope-profile" {
  managed = "goauthentik.io/providers/oauth2/scope-profile"
}

data "authentik_scope_mapping" "scope-email" {
  managed = "goauthentik.io/providers/oauth2/scope-email"
}

resource "authentik_scope_mapping" "scope-email-primary-address" {
  name        = "OAuth mapping: OpenID 'email' with mailPrimaryAddress"
  scope_name  = "email"
  description = "Email address"
  expression  = <<EOF
return {
  "email": request.user.attributes.get("mailPrimaryAddress", None),
  "email_verified": True,
}
EOF
}

resource "authentik_scope_mapping" "scope-user-pk" {
  name        = "OAuth mapping: OpenID 'user_pk'"
  scope_name  = "user_pk"
  description = "User ID"
  expression  = <<EOF
return {
  "id": request.user.pk,
}
EOF
}

resource "authentik_scope_mapping" "scope-username" {
  name        = "OAuth mapping: OpenID 'username'"
  scope_name  = "username"
  description = "Username"
  expression  = <<EOF
return {
  "username": request.user.username,
}
EOF
}
