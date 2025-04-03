terraform {
  required_providers {
    assert = {
      source  = "bwoznicki/assert"
      version = "0.0.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.25.0"
    }
  }

  backend "http" {}
}
