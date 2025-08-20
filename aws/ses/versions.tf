terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.8.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.2.0"
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
