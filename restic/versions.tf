terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "1.5.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.12.0"
    }
  }

  backend "http" {}
}

data "vault_generic_secret" "restic_wasabi-credentials" {
  path = "restic/wasabi-credentials"
}

# AWS provider to handle Wasabi S3 conf
provider "aws" {
  region     = "eu-central-1"
  access_key = data.vault_generic_secret.restic_wasabi-credentials.data["access_key"]
  secret_key = data.vault_generic_secret.restic_wasabi-credentials.data["secret_key"]

  endpoints {
    iam = "https://iam.eu-central-1.wasabisys.com"
    s3  = "https://s3.eu-central-1.wasabisys.com"
    sts = "https://sts.eu-central-1.wasabisys.com"
  }

  # Skip checks
  s3_use_path_style           = true
  skip_get_ec2_platforms      = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# Minio provider to create buckets because of a bug between the aws provider
# and Wasabi
provider "minio" {
  minio_server     = "localhost:9000"
  minio_region     = "eu-central-1"
  minio_access_key = data.vault_generic_secret.restic_wasabi-credentials.data["access_key"]
  minio_secret_key = data.vault_generic_secret.restic_wasabi-credentials.data["secret_key"]
}

provider "vault" {}
