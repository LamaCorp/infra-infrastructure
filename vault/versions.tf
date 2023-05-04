terraform {
  required_providers {
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "1.0.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.15.2"
    }
  }

  backend "http" {}
}
