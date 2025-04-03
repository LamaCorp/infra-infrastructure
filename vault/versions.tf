terraform {
  required_providers {
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "1.2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.20.0"
    }
  }

  backend "http" {}
}
