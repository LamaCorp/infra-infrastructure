terraform {
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }

    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "1.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.3.0"
    }
  }

  backend "http" {}
}
