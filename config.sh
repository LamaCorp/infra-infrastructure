#!/bin/sh

export VAULT_ADDR="https://vault.lama.tel:443"

load_secrets() {
  secrets_path="${1}"

  if ! [ -f "${secrets_path}" ]; then
    echo "You should create the ${secrets_path} file by running"
    echo "  cp ${secrets_path}.tpl ${secrets_path} && \$EDITOR ${secrets_path}"
  else
    . "${secrets_path}"
  fi
}

load_secrets "secrets/vars"

export GRAFANA_USER="$(vault kv get -field=username observability/grafana/admin)"
export GRAFANA_PASSWORD="$(vault kv get -field=password observability/grafana/admin)"
