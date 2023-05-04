terraform {
  required_providers {
    assert = {
      source  = "bwoznicki/assert"
      version = "0.0.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.15.2"
    }
  }

  backend "http" {}
}
