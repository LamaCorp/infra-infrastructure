terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2023.6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.20.0"
    }
  }

  backend "http" {}
}

provider "vault" {}

data "vault_generic_secret" "authentik_admin" {
  path = "authentik/admin"
}

provider "authentik" {
  url   = "https://auth.lama-corp.space"
  token = data.vault_generic_secret.authentik_admin.data["token"]
}
