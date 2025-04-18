terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "1.43.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.25.0"
    }
  }

  backend "http" {}
}

provider "vault" {}

data "vault_generic_secret" "observability_grafana_admin" {
  path = "observability/grafana/admin"
}

provider "grafana" {
  url  = "https://grafana.lama.tel"
  auth = "${data.vault_generic_secret.observability_grafana_admin.data["username"]}:${data.vault_generic_secret.observability_grafana_admin.data["password"]}"
}
