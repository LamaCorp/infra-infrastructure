terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.6.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.17.0"
    }
  }

  backend "http" {}
}

data "vault_generic_secret" "infra_aws_root" {
  path = "infra/aws/root"
}
provider "aws" {
  region     = "eu-west-3"
  access_key = data.vault_generic_secret.infra_aws_root.data["access_key"]
  secret_key = data.vault_generic_secret.infra_aws_root.data["secret_key"]
}

data "vault_generic_secret" "infra_cloudflare_root" {
  path = "infra/cloudflare/root"
}
provider "cloudflare" {
  email   = "marc.schmitt@lama-corp.space"
  api_key = data.vault_generic_secret.infra_cloudflare_root.data["api_key"]
}
