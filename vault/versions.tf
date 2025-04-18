terraform {
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "2.3.4"
    }

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
      version = "3.25.0"
    }
  }

  backend "http" {}
}
